select order_id, order_date
from {{ ref('stg_orders') }}
where order_date < '2025-01-01'