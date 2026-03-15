
#Ingestion of Election results per election,
#election type, province, municipality
#and voting station, into the bronze layer

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
csv_files = glob.glob('/app/data/Election Results/**/*.csv', recursive=True)


with engine.begin() as connection:  

    connection.execute(text("CREATE SCHEMA IF NOT EXISTS bronze"))

    #loop all csv files in the Election Results folder
    for file in csv_files:
        df = pd.read_csv(file, encoding='latin1', low_memory=False, on_bad_lines='skip')
        
        #standard naming conventions
        table_name = os.path.basename(file).replace('.csv', '').lower()
        table_name = table_name.replace(' ', '_').replace('(', '').replace(')', '').replace('-', '_')

        df.to_sql(table_name, con=connection, schema='bronze', if_exists='replace', index=False)
        
        print(f"{table_name} loaded successfully!")