{{ config(materialized="incremental") }}

with
activities as (select * from {{ ref("stg__activities") }}),

activities_arrays as (
    select
        id,
        start_time_ts,
        start_time_utc,
        json_extract_array(points, '$.time') as ts_array,
        json_extract_array(points, '$.watts') as watts_array,
        json_extract_array(points, '$.heart_rate') as heart_rate_array
    from activities
    {% if is_incremental() %}
        where start_time_utc > (select max(start_time_utc) from {{ this }})
    {% endif %}
),

activities_end_times as (
    select
        id,
        cast(max(ts) as int64) as end_time_ts
    from activities_arrays,
        unnest(ts_array) as ts
    group by id
),

activities_filled_in_ts as (
    select
        a.id,
        e.end_time_ts,
        generate_array(
            a.start_time_ts - {{ var("peak_time_ranges") | max }}, e.end_time_ts
        )
            as ts_array
    from activities_arrays as a
    inner join activities_end_times as e
        on a.id = e.id
),

activities_filled_in_ts_unnested as (
    select
        id,
        end_time_ts,
        ts
    from activities_filled_in_ts,
        unnest(ts_array) as ts
),

activities_unnested as (
    select
        id,
        start_time_ts,
        start_time_utc,
        cast(ts_value as int64) as ts,
        cast(watts_value as int64) as watts,
        watts / 1000.0 AS kjs,
        cast(heart_rate_value as int64) as heart_rate
    from
        activities_arrays,
        unnest(ts_array) as ts_value with offset as ts_offset,
        unnest(watts_array) as watts_value with offset as watts_offset,
        unnest(heart_rate_array) as heart_rate_value with offset
            as heart_rate_offset
    where
        ts_offset = watts_offset
        and ts_offset = heart_rate_offset
),

joined as (
    select
        f.id,
        f.end_time_ts,
        f.ts,
        max(a.start_time_ts) over (partition by f.id) as start_time_ts,
        max(a.start_time_utc) over (partition by f.id) as start_time_utc,
        coalesce(a.watts, 0) as watts,
        coalesce(a.kjs, 0) as kjs,
        coalesce(a.heart_rate, 0) as heart_rate
    from activities_filled_in_ts_unnested as f
    left join activities_unnested as a
        on
            f.id = a.id
            and f.ts = a.ts
),

final as (
    select
        id,
        start_time_ts,
        start_time_utc,
        end_time_ts,
        ts,
        watts,
        kjs,
        heart_rate
    from joined
)

select * from final
