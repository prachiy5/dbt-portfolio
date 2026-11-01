{% set statuses=['placed', 'completed', 'returned'] %}

select customer_id, 
       {% for s in statuses %}
       sum(case when status = '{{ s }}' then amount else 0 end) as {{ s }}_amount
       {%- if not loop.last %},{% endif %}
       {% endfor %}
from {{ ref('stg_orders') }}
group by 1
