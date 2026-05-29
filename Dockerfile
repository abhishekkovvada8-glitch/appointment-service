# -----------------------------
# Base Image
# -----------------------------
FROM python:3.12-slim

# -----------------------------
# Environment Variables
# -----------------------------
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# -----------------------------
# System Dependencies
# -----------------------------
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------
# Create Non-Root User
# -----------------------------
RUN useradd -m appuser

# -----------------------------
# Set Working Directory
# -----------------------------
WORKDIR /app

# -----------------------------
# Install Dependencies
# -----------------------------
COPY requirements.txt .

RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# -----------------------------
# Copy Application
# -----------------------------
COPY . .

# -----------------------------
# Change Ownership
# -----------------------------
RUN chown -R appuser:appuser /app

USER appuser

# -----------------------------
# Expose Port
# -----------------------------
EXPOSE 8000

# -----------------------------
# Health Check
# -----------------------------
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
CMD curl -f http://localhost:8000/health || exit 1

# -----------------------------
# Start Application
# -----------------------------
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "2"]
