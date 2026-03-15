
#Ingestion of population data (to enrich voting district data)

import time
import pandas as pd
from sqlalchemy import create_engine, text
from sqlalchemy.exc import OperationalError
import glob
import os

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


#locate all the csv files in the Election Results folder
xlsx_files = glob.glob('/app/data/Stats SA Census/**/*.xlsx', recursive=True)


with engine.begin() as connection:  

    connection.execute(text("CREATE SCHEMA IF NOT EXISTS bronze"))

    #loop all csv files in the MDB Ward Shape 2020 folder
    for file in xlsx_files:
        df = pd.read_excel(file, engine='openpyxl')
        
        #standard naming conventions
        table_name = os.path.basename(file).replace('.xlsx', '').lower()
        table_name = table_name.replace(' ', '_').replace('(', '').replace(')', '').replace('-', '_')

        df.to_sql(table_name, con=connection, schema='bronze', if_exists='replace', index=False)
        
        print(f"{table_name} loaded successfully!")