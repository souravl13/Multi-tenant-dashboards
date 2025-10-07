# Base image
FROM python:3.9-slim

# Set workdir
WORKDIR /app

# Copy requirements and install
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy Python app
COPY app/ .

# Copy frontend files
COPY templates/ ./templates/
COPY static/ ./static/

# Expose Flask port
EXPOSE 5000

# Run Flask app
CMD ["python", "main.py"]
