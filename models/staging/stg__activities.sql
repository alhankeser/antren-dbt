with
    source as (select * from {{ ref("src__activities") }}),

    updated as (
        select
            id,
            start_time_ts,
            timestamp_seconds(start_time_ts) as start_time_utc,
            points,
        from source
    ),

    final as (
        select 
            id,
            start_time_ts,
            start_time_utc,
            points
        from updated
    )

select * from final
