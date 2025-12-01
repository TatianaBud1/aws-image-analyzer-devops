FROM python:3.11-slim

WORKDIR /app

# Copiem fișierele din folderul 'app' în container
COPY app/requirements.txt ./requirements.txt
COPY app/ ./ 

# Instalăm dependențele
RUN pip install --no-cache-dir -r requirements.txt

# Expunem portul pe care rulează Flask
EXPOSE 8000

# Comanda de start
CMD ["python", "main.py"]
