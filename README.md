# dbt Portfolio Project: Customers and Orders

An analytics engineering project built with **dbt Core** and **DuckDB**. It takes raw customer and order data through staging, tested marts, and an incremental fact table, using the same practices a production dbt project uses.

## Why I built this

I'm a data analyst moving into analytics engineering. This project is my hands-on practice with the full dbt workflow: modeling in layers, testing data quality, documenting, tracking history, and building efficiently.

## Project layers

```
raw seeds (simulated source data)
    -> staging   (stg_customers, stg_orders)    views, light cleaning
    -> marts     (dim_customers, fct_orders)    tables / incremental
```

| Layer | Models | What it does |
|---|---|---|
| Sources | `raw.raw_customers`, `raw.raw_orders` | Declared in `_sources.yml`, with freshness checks on orders |
| Staging | `stg_customers`, `stg_orders` | Rename columns, cast types, lowercase emails, convert cents to dollars |
| Marts | `dim_customers` | One row per customer with order count, spend, first and latest order dates |
| Marts | `fct_orders` | Incremental fact table filtered on `loaded_at` so late-arriving orders are not missed |
| Snapshots | `customers_snapshot` | SCD Type 2 history of customer changes (`dbt_valid_from` / `dbt_valid_to`) |

## Key design decisions

- **Business rules live in one place.** Which order statuses count as spend is defined in the `status_labels` seed, not hardcoded in SQL.
- **Staging keeps every row.** Filtering (for example, excluding returned orders from spend) happens in the marts layer, so nothing is lost for other uses like return-rate reporting.
- **Incremental on load time, not business date.** Late orders have old order dates but new load times, so filtering on `loaded_at` with a `unique_key` avoids silently skipping them.
- **Tests gate the build.** With `dbt build`, a failed test upstream causes downstream models to be skipped, so bad data does not reach marts.

## Data quality

- **Generic tests:** `unique`, `not_null`, `accepted_values`, and `relationships` (every order belongs to a real customer)
- **Package test:** `dbt_utils.accepted_range` to ensure order amounts are not negative
- **Singular tests:** custom SQL for business rules, such as orders not dated before launch
- **Source freshness:** `dbt source freshness` flags stale raw data

## Jinja and packages

- Reusable macro: `cents_to_dollars(column, decimal_places)`
- Package: `dbt_utils`

## Lineage

![Lineage graph](docs/lineage.png)

## Run it yourself

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install dbt-core dbt-duckdb
dbt deps
dbt seed
dbt build
dbt docs generate && dbt docs serve
```

A `profiles.yml` for DuckDB is needed in `~/.dbt/`:

```yaml
portfolio_dbt:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: dev.duckdb
      threads: 4
```

## Fast CI with state comparison

```bash
dbt build --select state:modified+ --defer --state prod_state
```

Builds only changed models and their dependents, reading unchanged upstream models from production.

## Tech

dbt Core, DuckDB, dbt_utils, SQL, Jinja, Git/GitHub

## Author

Prachi Yadav | [LinkedIn](https://www.linkedin.com/in/prachi-yadav-559222189/) | [GitHub](https://github.com/prachiy5)
