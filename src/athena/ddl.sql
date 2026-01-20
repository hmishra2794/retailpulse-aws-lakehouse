-- Database
CREATE DATABASE IF NOT EXISTS retailpulse;

-- FACT table (Gold)
CREATE EXTERNAL TABLE IF NOT EXISTS retailpulse.fact_orders (
  event_id string,
  event_type string,
  event_ts timestamp,
  customer_id string,
  order_id string,
  amount double
)
PARTITIONED BY (event_date date)
STORED AS PARQUET
LOCATION 's3://retailpulse-gold-206470327951/fact_orders/';

-- AGG table (Gold)
CREATE EXTERNAL TABLE IF NOT EXISTS retailpulse.agg_daily_revenue (
  daily_revenue double
)
PARTITIONED BY (event_date date)
STORED AS PARQUET
LOCATION 's3://retailpulse-gold-206470327951/agg_daily_revenue/';

-- Load partitions (because we used partitioned folders)
MSCK REPAIR TABLE retailpulse.fact_orders;
MSCK REPAIR TABLE retailpulse.agg_daily_revenue;
