import pandas as pd
from sqlalchemy import create_engine, text

# Connect from Python container to Postgres container
postgresql_url = 'postgresql://postgres:password@db:5432/IEC2029_Database'

engine = create_engine(postgresql_url)
connection = engine.connect()

with engine.connect() as connection:
    print("Connection successful!")

    
    connection.execute(text("CREATE SCHEMA IF NOT EXISTS bronze;"))
    print("Schema 'bronze' is ready.")

   
    df = pd.read_csv('/app/data/National(Results Report - National).csv')  
    print("CSV loaded successfully!")

    
    df.to_sql('users', con=connection, schema='bronze', if_exists='replace', index=False)
    print("Data ingested into bronze.users successfully!")