FROM python:3.11-slim

WORKDIR /app

#  ping to test connection between containers
RUN apt-get update && \
    apt-get install -y postgresql-client  iputils-ping && \
    apt-get clean


COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8888

CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]