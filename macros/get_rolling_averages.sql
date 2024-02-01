{% macro get_rolling_averages(column, time_ranges, partition_by_columns="id", order_by_columns="ts") -%}

{%- for time_range in time_ranges %}
            avg({{ column }}) over (
                        partition by {{ partition_by_columns }} 
                        order by {{ order_by_columns }} 
                        range between {{ time_range }} preceding and current row
                    ) as rolling_{{ get_duration_label(time_range) }}_{{ column }}
            {%- if not loop.last -%}
                ,
            {%- endif -%}
{%- endfor -%}
{% endmacro %}

