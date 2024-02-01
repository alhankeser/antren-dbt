{%- macro get_max_over_lookbacks(columns, order_by_columns, lookback_windows) -%}
    {%- for column in columns -%}
    {%- set column = column | replace("`","") -%}
        {% for lookback in lookback_windows %}
            max({{ column }}) over (
                order by
                    {{ order_by_columns }} range
                    between {{ lookback }} preceding and current row
            ) as {{ column }}_r{{ lookback }}d
            {%- if not loop.last -%}
                ,
            {%- endif %}
        {%- endfor -%}
        {%- if not loop.last -%}
            ,
        {%- endif %}
    {%- endfor -%}
{%- endmacro -%}
