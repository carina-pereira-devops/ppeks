FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r service1/requirements.txt
COPY . .
EXPOSE 5001  
CMD ["python", "app.py"]


