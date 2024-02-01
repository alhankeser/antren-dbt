{%- macro get_max_over_lookbacks_columns(columns, lookback_windows) -%}
{%- set output_column_list = [] -%}
    {%- for column in columns -%}
    {%- set column = column | replace("`","") | replace("\n  ", "") -%}
        {%- for lookback in lookback_windows -%}
            {%- set output_column_list = output_column_list.extend([column ~ "_r" ~ lookback ~ "d"]) -%}
        {%- endfor -%}
    {%- endfor -%}
{{ output_column_list }}
{%- endmacro -%}