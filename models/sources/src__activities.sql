with
    base as (select * from {{ source("antren_app", "activities") }}),

    final as (
        select
            activity_id as id, 
            start_time as start_time_ts, 
            data as points
        from base
    )

select * from final

{% if target.name == 'dev' %}
    where timestamp_seconds(start_time_ts) > timestamp_sub(current_timestamp(), interval 14 day)
{% endif %}
