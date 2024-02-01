{% macro get_peak_rolling_averages(column, time_ranges) -%}

{%- for time_range in time_ranges %}
            max(rolling_{{ get_duration_label(time_range) }}_{{ column }}) as peak_{{ get_duration_label(time_range) }}_{{ column }}
            {%- if not loop.last -%}
                ,
            {%- endif -%}
{%- endfor -%}
{% endmacro %}

