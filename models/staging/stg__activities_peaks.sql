with
    activities_points as (select * from {{ ref("stg__activities_points") }}),

    activities_rolling_averages as (
        select
            activities_points.*,
            {{- get_rolling_averages(
                                column="watts", 
                                time_ranges=var("peak_time_ranges"), 
                                partition_by_columns="id", 
                                order_by_columns="ts")}}
        from activities_points
    ),

    activities_peaks as (
        select 
            id, 
            start_time_utc, 
            {{- get_peak_rolling_averages(column="watts", time_ranges=var("peak_time_ranges"))}}
        from activities_rolling_averages
        group by id, start_time_utc
    ),

    final as (select * from activities_peaks)

select *
from final
