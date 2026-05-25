{% test invalid_status_check(model, column_name, invalid_values) %}

select *
from {{ model }}
where {{ column_name }} in (
    {% for val in invalid_values %}
        '{{ val | lower }}', '{{ val | upper }}'
        {% if not loop.last %},{% endif %}
    {% endfor %}
)

{% endtest %}
