import json
import logging
import os

LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO").upper()
logging.getLogger().setLevel(LOG_LEVEL)
logger = logging.getLogger(__name__)

# this Lambda function is designed to be triggered by S3 events.
# it logs the details of the uploaded object, including the bucket name, object key
def lambda_handler(event, context):
    """
    This function is triggered by S3 ObjectCreated events.
    It logs the bucket and object key that was uploaded.
    """
    logger.info("Received event: %s", json.dumps(event))

    try:
        for record in event.get("Records", []):
            bucket = record["s3"]["bucket"]["name"]
            key    = record["s3"]["object"]["key"]
            size   = record["s3"]["object"].get("size", "unknown")

            logger.info("New object uploaded: s3://%s/%s (size=%s)", bucket, key, size)

        return {"statusCode": 200, "body": "Processed upload event."}
    except Exception as e:
        logger.exception("Error processing event")
        return {"statusCode": 500, "body": f"Error: {e}"}
