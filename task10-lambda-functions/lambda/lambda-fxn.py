import json
import logging
import os
import boto3

# Environment variables for flexibility
SES_FROM = os.getenv("SES_FROM", "kenechukwuojiteli@gmail.com")
SES_TO   = os.getenv("SES_TO", "kenechukwuojiteli@gmail.com")

# Initialize SES client
ses = boto3.client("ses", region_name="us-east-1")

# Setup logging
LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO").upper()
logging.getLogger().setLevel(LOG_LEVEL)
logger = logging.getLogger(__name__)

def lambda_handler(event, context): # lambda's entrypoint
    """
    Triggered by S3 ObjectCreated events.
    Logs details of uploaded object and sends SES confirmation email.
    """
    logger.info("Received event: %s", json.dumps(event))

    try:
        for record in event.get("Records", []):
            bucket = record["s3"]["bucket"]["name"]
            key    = record["s3"]["object"]["key"]
            size   = record["s3"]["object"].get("size", "unknown")

            # logger.info("New object uploaded: s3://%s/%s (size=%s)", bucket, key, size)
            logger.info(f"New object uploaded: s3://{bucket}/{key}/{size}") # preferred formatting with f-string

            # Send confirmation email
            send_email(
                subject=f"New file uploaded: {key}",
                body=f"A new file was uploaded to bucket '{bucket}':\n\nFile: {key}\nSize: {size} bytes"
            )

        return {"statusCode": 200, "body": "Processed upload event and sent email."}
    except Exception as e:
        logger.exception("Error processing event")
        return {"statusCode": 500, "body": f"Error: {e}"}

def send_email(subject, body):
    """Helper function to send an SES email"""
    try:
        response = ses.send_email(
            Source=SES_FROM,
            Destination={"ToAddresses": [SES_TO]},
            Message={
                "Subject": {"Data": subject},
                "Body": {
                    "Text": {"Data": body}
                }
            }
        )
        logger.info("Email sent successfully: %s", response)
    except Exception as e:
        logger.exception("Failed to send email")
        raise
