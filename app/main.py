from flask import Flask, request, jsonify
import boto3

app = Flask(__name__)

BUCKET = "tatiana-photo-analyzer3"
TABLE = "ImageLabels"

@app.route("/health")
def health():
    return {"status": "ok"}

@app.route("/analyze", methods=["POST"])
def analyze():
    file = request.files["image"]
    filename = file.filename

    s3 = boto3.client("s3")
    rekognition = boto3.client("rekognition")
    dynamodb = boto3.client("dynamodb")

    # 1. Urcare în S3
    s3.upload_fileobj(file, BUCKET, filename)

    # 2. Analiză cu Rekognition
    result = rekognition.detect_labels(
        Image={"S3Object": {"Bucket": BUCKET, "Name": filename}},
        MaxLabels=5
    )

    # 3. Salvare în DynamoDB
    dynamodb.put_item(
        TableName=TABLE,
        Item={
            "image_name": {"S": filename},
            "labels": {"S": str(result["Labels"])}
        }
    )

    return jsonify(result["Labels"])
