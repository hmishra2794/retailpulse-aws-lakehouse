import json
import os
from datetime import datetime, timezone

import boto3

s3 = boto3.client("s3")

def _get_env():
    raw_bucket = os.environ["RAW_BUCKET"]  # required
    raw_prefix = os.environ.get("RAW_PREFIX", "events")
    return raw_bucket, raw_prefix



def _utc_date_from_event(event_time: str) -> str:
    """
    event_time is expected in ISO-8601 format, e.g. '2026-01-14T12:00:00Z'
    """
    if event_time.endswith("Z"):
        event_time = event_time.replace("Z", "+00:00")
    dt = datetime.fromisoformat(event_time).astimezone(timezone.utc)
    return dt.strftime("%Y-%m-%d")


def handler(event, context):
    """
    Triggered by SQS.
    Each record["body"] is an EventBridge envelope JSON string.
    """
    records = event.get("Records", [])
    raw_bucket, raw_prefix = _get_env()

    for record in records:
        envelope = json.loads(record.get("body", "{}"))

        detail = envelope.get("detail", {})
        event_type = detail.get("event_type") or envelope.get("detail-type") or "unknown"
        event_id = detail.get("event_id") or envelope.get("id") or record.get("messageId")

        # prefer event's timestamp; fall back to EventBridge time
        event_ts = detail.get("event_ts") or envelope.get("time") or datetime.now(timezone.utc).isoformat()
        dt = _utc_date_from_event(event_ts)

        key = f"{raw_prefix}/event_type={event_type}/dt={dt}/{event_id}.json"

        payload = {
            "envelope": envelope,
            "detail": detail,
        }

        s3.put_object(
            Bucket=raw_bucket,
            Key=key,
            Body=(json.dumps(payload) + "\n").encode("utf-8"),
            ContentType="application/json",
        )

    return {"status": "ok", "records": len(records)}

