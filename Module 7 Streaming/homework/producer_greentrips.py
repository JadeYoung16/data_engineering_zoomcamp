import dataclasses
import json
import sys
import time
from pathlib import Path
import pandas as pd
from kafka import KafkaProducer

current_file_path = Path(__file__).resolve()
src_directory = current_file_path.parent.parent
sys.path.insert(0, str(src_directory))

url = "https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2025-10.parquet"
columns = ['PULocationID', 'DOLocationID', 'trip_distance', 'tip_amount','total_amount', 'lpep_pickup_datetime','lpep_dropoff_datetime','passenger_count']
df = pd.read_parquet(url, columns=columns)
df = df.fillna(0)

def green_ride_serializer(data):
    ride_dict = dataclasses.asdict(data)
    json_str = json.dumps(ride_dict)
    return json_str.encode('utf-8')

server = 'localhost:9092'
producer = KafkaProducer(
    bootstrap_servers=[server],
    value_serializer=green_ride_serializer
)


from models import GreenRide,green_ride_from_row
import time

t0 = time.time()
topic_name ='green-trips'

for _, row in df.iterrows():
    ride = green_ride_from_row(row)
    ride.lpep_pickup_datetime = int(row['lpep_pickup_datetime'].timestamp() * 1000)
    producer.send(topic_name, value=ride)


producer.flush()

t1 = time.time()
print(f'took {(t1 - t0):.2f} seconds')





