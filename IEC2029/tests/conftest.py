import psycopg2
import pytest
from dotenv import load_dotenv, find_dotenv
import os

load_dotenv(find_dotenv(), override=True)

# Shared DB connection fixture — available to all test files
@pytest.fixture(scope="session")
def db_conn():
    conn = psycopg2.connect(
        dbname=os.getenv('DB_NAME'),
        user=os.getenv('DB_USER'),
        password=os.getenv('DB_PASSWORD'),
        host=os.getenv('DB_HOST'),
        port=os.getenv('DB_PORT')
    )
    yield conn
    conn.close()