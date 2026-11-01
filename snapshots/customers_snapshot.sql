{% snapshot customers_snapshot %}

{{
    config(
        schema='snapshots',
        unique_key='id',
        strategy='check',
        check_cols=['first_name', 'last_name', 'email']
    )
}}

select * from {{ source('raw', 'raw_customers') }}

{% endsnapshot %}