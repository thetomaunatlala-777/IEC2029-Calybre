import requests
import json
from pathlib import Path
from sqlalchemy import create_engine, text
from sqlalchemy.exc import OperationalError
from dotenv import load_dotenv, find_dotenv
import os
import time

load_dotenv(find_dotenv(), override=True)

base_url = "https://api.elections.org.za/IECGIS/api/VotingDistrict?vdnumber={}&returnGeom=Yes"
vd_file = Path("/app/notebooks/vd_nums.json")
postgresql_url = (
    f"postgresql://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}"
    f"@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
)
max_retries = 3
timeout_seconds = 20

with vd_file.open("r") as f:
    vd_nums = json.load(f)

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

with engine.begin() as connection:
    connection.execute(text("CREATE SCHEMA IF NOT EXISTS bronze"))
    connection.execute(text("""
        CREATE TABLE IF NOT EXISTS bronze.voting_stations (
            vd_number INT PRIMARY KEY,
            api_response JSONB NOT NULL
        )
    """))

    for vd in vd_nums:
        for attempt in range(max_retries):
            try:
                response = requests.get(base_url.format(vd), timeout=timeout_seconds)
                if response.status_code == 200:
                    data = response.json()
                    connection.execute(
                        text("""
                            INSERT INTO bronze.voting_stations (vd_number, api_response)
                            VALUES (:vd_number, :api_response)
                            ON CONFLICT (vd_number) DO NOTHING
                        """),
                        {"vd_number": vd, "api_response": json.dumps(data)}
                    )
                    print(f"Inserted VD {vd}")
                    break
                else:
                    print(f"VD {vd} failed with status {response.status_code}")
                    time.sleep(2 ** attempt)
            except requests.exceptions.RequestException as e:
                print(f"Error for VD {vd}: {e} (attempt {attempt+1})")
                time.sleep(2 ** attempt)
