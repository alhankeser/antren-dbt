{{ config(materialized="incremental") }}

with
    activities as (select * from {{ ref("int__activities") }}),

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
            where start_time_ts > (select max(start_time_ts) from {{ this }})
        {% endif %}
    ),

    activities_unnested as (
        select
            id,
            start_time_ts,
            start_time_utc,
            cast(ts_value as int64) as ts,
            cast(watts_value as int64) as watts,
            cast(heart_rate_value as int64) as heart_rate
        from
            activities_arrays,
            unnest(ts_array) as ts_value with offset as ts_offset,
            unnest(watts_array) as watts_value with offset as watts_offset,
            unnest(heart_rate_array) as heart_rate_value with offset as heart_rate_offset
        where
            ts_offset = watts_offset
            and ts_offset = heart_rate_offset
    ),

    final as (
        select 
            id, 
            start_time_ts, 
            start_time_utc, 
            ts,
            watts, 
            heart_rate 
        from activities_unnested
    )

select * from final
