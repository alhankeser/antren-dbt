-- For some reason the columns list being passed in is 
-- not behaving like a list so I have to force it to do so. 
{% macro get_max(columns) %}
{%- set column_list = columns.split(",") -%}
    {%- for column in column_list -%}
    {%- set column = column | replace("'","") | replace("[","") | replace("]","") -%}
    {%- set column = column | replace(" ","") -%}
    max({{- column -}}) as max_{{- column -}}
    {%- if not loop.last -%}
        ,
    {%- endif %}
    {% endfor %}
{% endmacro %}