{% macro show_databases() %}
  {% set show_databases_query %}
    SHOW DATABASES;
  {% endset %}

  {% set results = run_query(show_databases_query) %}

  {% if execute %}
    {% do log(results.columns[0].values(), info=true) %}
  {% endif %}
{% endmacro %}