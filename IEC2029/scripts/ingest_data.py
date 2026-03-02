import time
import pandas as pd
from sqlalchemy import create_engine, text
from sqlalchemy.exc import OperationalError

postgresql_url = 'postgresql://postgres:password@db:5432/IEC2029_Database'
engine = create_engine(postgresql_url)

# Wait until Postgres is ready
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

schemas = ['bronze', 'silver', 'gold']


with engine.begin() as connection:  
    for schema in schemas:
        connection.execute(text(f"CREATE SCHEMA IF NOT EXISTS {schema};"))
        print(f"Schema '{schema}' is ready.")

    # Load CSV
    df = pd.read_csv('/app/data/National(Results Report - National).csv')
    df.to_sql('national_results', con=connection, schema='bronze', if_exists='replace', index=False)
    print("Data ingested into bronze.national_results successfully!")