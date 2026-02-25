FROM python:3.11-slim

WORKDIR /app

# Install PostgreSQL client + git
RUN apt-get update && \
    apt-get install -y postgresql-client && \
    apt-get clean

# Install Python packages
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8888

CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]