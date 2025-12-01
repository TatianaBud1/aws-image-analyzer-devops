# Proiect DevOps – AWS Image Analyzer
Autor: Tatiana Budaianu

Bucket personalizat S3:
*tatiana-photo-analyzer3*

## Funcționalitate
- primește imagini
- le salvează în S3 (tatiana-photo-analyzer3)
- le analizează cu AWS Rekognition
- salvează rezultatele în DynamoDB

## Pași de rulare local
pip install -r app/requirements.txt  
python app/main.py

## Infrastructură
terraform init  
terraform apply