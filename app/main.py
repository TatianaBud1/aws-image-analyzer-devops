from flask import Flask, request, jsonify
import boto3

app = Flask(__name__)

# conectare AWS Rekognition și S3
rekognition = boto3.client('rekognition', region_name='eu-central-1')
s3 = boto3.client('s3')
BUCKET = 'tatiana-photo-analyzer3'  # creează-l în AWS S3

@app.route('/')
def home():
    return "Bun venit în aplicația Tatiana – Analiză imagini cu AWS Rekognition!"

@app.route('/analyze', methods=['POST'])
def analyze_image():
    if 'image' not in request.files:
        return jsonify({"eroare": "Nu a fost trimis niciun fișier"}), 400

    file = request.files['image']
    try:
        s3.upload_fileobj(file, BUCKET, file.filename)
        result = rekognition.detect_labels(
            Image={'S3Object': {'Bucket': BUCKET, 'Name': file.filename}},
            MaxLabels=5
        )
        labels = [label['Name'] for label in result['Labels']]
        return jsonify({
            "imagine": file.filename,
            "etichete_detectate": labels,
            "numar_etichete": len(labels)
        })
    except Exception as e:
        return jsonify({"eroare": str(e)}), 500

if __name__ == '__main__':
   app.run(host='0.0.0.0', port=8000, debug=True)
