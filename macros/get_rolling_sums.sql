{% macro get_rolling_sums(column, time_ranges, order_by_columns="ts") -%}

{%- for time_range in time_ranges %}
            sum({{ column }}) over (
                        order by {{ order_by_columns }} 
                        range between {{ time_range }} preceding and current row
                    ) as rolling_{{ time_range }}d_{{ column }}
            {%- if not loop.last -%}
                ,
            {%- endif -%}
{%- endfor -%}
{% endmacro %}

