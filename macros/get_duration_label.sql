{%- macro get_duration_label(duration_seconds) -%}
    {%- if duration_seconds < 60 -%}
        {%- set duration_label = duration_seconds -%}
        {{ duration_seconds | int }}sec
    {%- elif duration_seconds >= 60 and duration_seconds < (60 * 60)-%}
        {%- set duration_label = duration_seconds / 60 -%}
        {{ duration_label | int }}min
    {%- elif duration_seconds >= (60 * 60) -%}
        {%- set duration_label = duration_seconds / (60 * 60) -%}
        {{ duration_label | int }}hr
    {%- endif -%}
{%- endmacro -%}