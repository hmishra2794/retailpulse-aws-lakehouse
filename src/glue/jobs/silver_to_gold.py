import sys
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.utils import getResolvedOptions
from pyspark.sql.functions import col, sum as _sum

args = getResolvedOptions(sys.argv, ["SILVER_PATH", "GOLD_FACT_PATH", "GOLD_AGG_PATH"])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

silver_df = spark.read.parquet(args["SILVER_PATH"])

# FACT table: one row per order event
fact_orders = (
    silver_df
    .select(
        col("event_id"),
        col("event_type"),
        col("event_ts"),
        col("event_date"),
        col("customer_id"),
        col("order_id"),
        col("amount"),
    )
)

(
    fact_orders
    .write
    .mode("append")
    .partitionBy("event_date")
    .parquet(args["GOLD_FACT_PATH"])
)

# AGG table: daily revenue
agg_daily_revenue = (
    silver_df
    .groupBy(col("event_date"))
    .agg(_sum(col("amount")).alias("daily_revenue"))
)

(
    agg_daily_revenue
    .write
    .mode("overwrite")
    .partitionBy("event_date")
    .parquet(args["GOLD_AGG_PATH"])
)
