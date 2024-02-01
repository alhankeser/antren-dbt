{{ config(materialized="table") }}

{% set peak_columns = dbt_utils.star(
                            from=ref("stg__activities_peaks"), 
                            except=["id",
                                    "start_time_ts",
                                    "start_time_utc", 
                                    "end_time_ts"]).split(",")
%}
{% set lookbacks_columns = get_max_over_lookbacks_columns(
                                            columns=peak_columns, 
                                            lookback_windows=var("lookback_windows")
                                            )
%}

with
    activities_peaks as (select * from {{ ref("stg__activities_peaks") }}),

    dates as (select * from {{ ref("util__dates") }}),

    maxes_per_day as (
        select 
            dates.date_day,
            {{
                get_max_over_lookbacks(
                        columns=peak_columns, 
                        order_by_columns="unix_date(cast(dates.date_day as date))",
                        lookback_windows=var("lookback_windows")
                        )
            }}
        from dates
        left join activities_peaks a 
            on cast(a.start_time_utc as date) = dates.date_day
        where
            dates.date_day between cast(
                '{{ var("training_start_date") }}' as datetime
            ) and cast(current_date() as datetime)
    ),
    
    final as (
        select
            date_day,
            {{ get_max(lookbacks_columns) }}
        from maxes_per_day
        group by date_day
    )

select *
from final
