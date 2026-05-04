# Ingestion of MDB Wards data (to enrich voting district data)
import time
import pandas as pd
from sqlalchemy import create_engine, text
from sqlalchemy.exc import OperationalError
from dotenv import load_dotenv, find_dotenv
import glob
import os

load_dotenv(find_dotenv(), override=True)

postgresql_url = (
    f"postgresql://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}"
    f"@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
)
engine = create_engine(postgresql_url)

for i in range(10):
    try:
        with engine.connect() as conn:
            print("Connection successful!")
            break
    except OperationalError:
        print("Postgres not ready, waiting 3s...")
        time.sleep(3)
else:
    raise Exception("Could not connect to Postgres after 10 tries")

csv_files = glob.glob('/app/data/MDB Ward Shape 2020/**/*.csv', recursive=True)

with engine.begin() as connection:
    connection.execute(text("CREATE SCHEMA IF NOT EXISTS bronze"))
    for file in csv_files:
        df = pd.read_csv(file, encoding='utf-8-sig', low_memory=False, on_bad_lines='skip')
        table_name = os.path.basename(file).replace('.csv', '').lower()
        table_name = table_name.replace(' ', '_').replace('(', '').replace(')', '').replace('-', '_')
        df.to_sql(table_name, con=connection, schema='bronze', if_exists='replace', index=False, chunksize=10000, method='multi')
        print(f"{table_name} loaded successfully!")
