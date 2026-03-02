# IEC2029 — Setup Guide

## 📌 Project Overview

This project implements a containerized data platform using Docker, PostgreSQL, and Python notebooks.
The system follows a layered data architecture (Medallion model) with separate schemas for:

* **bronze** — raw ingested data
* **silver** — transformed data
* **gold** — business-ready data

The goal is to provide a reproducible environment that any user can run.

---

# 1. Prerequisites

Install the following before running the project:

| Tool           | Version | Download                                       |
| -------------- | ------- | ---------------------------------------------- |
| Docker Desktop | Latest  | https://www.docker.com/products/docker-desktop |
| Git            | Latest  | https://git-scm.com                            |
| Python         | 3.11+   | https://www.python.org                         |

---

# 2. Local Environment Setup

### Clone repository

```
git clone https://github.com/thetomaunatlala-777/IEC2029-Calybre.git
cd IEC2029-Calybre/IEC2029
```

### Create environment file

Create a `.env` file in the project root:

```
POSTGRES_USER=postgres
POSTGRES_PASSWORD=password
POSTGRES_DB=IEC2029_Database
```

---

# 3. Build and Run Containers

### Start containers

```
docker compose up -d --build
```

### Check running containers

```
docker ps
```

You should see:

* postgres container
* python container

---

### Stop containers

```
docker compose down
```

---

# 4. Database Connection Details (for DBeaver)

| Setting  | Value            |
| -------- | ---------------- |
| Host     | localhost        |
| Port     | 5332             |
| Database | IEC2029_Database |
| Username | postgres         |
| Password | (from .env)      |

---



# 5. Database Schema Structure

Schemas represent Medallion layers:

```
bronze
silver
gold
```

View schemas:

```
docker compose exec db psql -U postgres -d IEC2029_Database -c "\dn"
```

---

# 6. Project Structure

```
IEC2029/
│
├── docker-compose.yml
├── Dockerfile
├── requirements.txt
├── notebooks/
├── config/
├── data/
├── docs/
├── scripts/
├── app.py/
└── sql/

```

# 7. Troubleshooting

### Database not connecting

Check container health:

```
docker ps
```

### Port already in use

Change port mapping in docker-compose.yml.

### Reset database

```
docker compose down -v
docker compose up -d
```


---

# 👤 Author

Theto Maunatlala (Calybre Consultant)

---

