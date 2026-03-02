# app.py
import time
while True:
    print("Python container is running...")
    time.sleep(4) #this delay allows the database container to start up before the application tries to connect to it, preventing connection errors during startup.
