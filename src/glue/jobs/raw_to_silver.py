import sys
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.utils import getResolvedOptions
from pyspark.sql.functions import col, to_date

args = getResolvedOptions(sys.argv, ["RAW_PATH", "SILVER_PATH"])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

# Read RAW JSON
raw_df = spark.read.json(args["RAW_PATH"])

# Extract fields from detail (because raw files are {envelope, detail})
d = raw_df["detail"]

# Enforce schema + transformations
silver_df = (
    raw_df
    .select(
        d["event_id"].alias("event_id"),
        d["event_type"].alias("event_type"),
        d["event_ts"].cast("timestamp").alias("event_ts"),
        d["customer_id"].alias("customer_id"),
        d["order_id"].alias("order_id"),
        d["amount"].cast("double").alias("amount"),
    )
    .withColumn("event_date", to_date(col("event_ts")))
)

# Write Parquet to SILVER
(
    silver_df
    .write
    .mode("append")
    .partitionBy("event_date")
    .parquet(args["SILVER_PATH"])
)
