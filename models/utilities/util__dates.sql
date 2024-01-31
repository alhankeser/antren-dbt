{{ dbt_utils.date_spine(
    datepart="day",
    start_date="cast('2014-01-01' as date)",
    end_date="date_trunc(date_add(current_date(), interval 2 year), year)"
   )
}}