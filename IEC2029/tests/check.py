
#Ingestion of Election results per election,
#election type, province, municipality
#and voting station, into the bronze layer
import time
import pandas as pd
from sqlalchemy import create_engine, text
from sqlalchemy.exc import OperationalError
import glob
from dotenv import load_dotenv, find_dotenv
import os




#locate all the csv files in the Election Results folder
csv_files = glob.glob('/app/data/Election Results/2024_Provincial.csv', recursive=False)


    #loop all csv files in the Election Results folder

df = pd.read_csv(r'C:\Users\ThetoMaunatlala\Documents\IEC2029-Calybre\IEC2029\data\Election Results\2024_Provincial.csv', encoding='latin1', low_memory=False, on_bad_lines='skip')
#print(df.to_string())
print(df.count())
        