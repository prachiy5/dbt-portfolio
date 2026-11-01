
with customers as (

    select * from {{ ref('stg_customers') }}

),

orders as (

    select * from {{ ref('stg_orders') }}

),

customer_orders as (

    select
        customer_id,
        count(*) as order_count,
        sum(case when s.counts_as_spend then amount else 0 end) as total_spend,
        min(order_date) as first_order_date,
        max(order_date) as most_recent_order_date
    from orders
    left join {{ ref('status_labels') }} s on s.status=orders.status
    group by 1

)

select
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.signup_date,
    coalesce(co.order_count, 0) as order_count,
    coalesce(co.total_spend, 0) as total_spend,
    co.first_order_date,
    co.most_recent_order_date
from customers c
left join customer_orders co
    on c.customer_id = co.customer_id