import io
import os
import requests
import pandas as pd
from google.cloud import storage

"""
Pre-reqs: 
1. `pip install pandas pyarrow google-cloud-storage`
2. Set GOOGLE_APPLICATION_CREDENTIALS to your project/service-account key
3. Set GCP_GCS_BUCKET as your bucket or change default value of BUCKET
"""

# services = ['fhv','green','yellow']
init_url = 'https://github.com/DataTalksClub/nyc-tlc-data/releases/download/'
# switch out the bucketname
BUCKET = os.environ.get("GCP_GCS_BUCKET", "zoomcamp-jadeyang-2026")


def upload_to_gcs(bucket, object_name, local_file):
    """
    Ref: https://cloud.google.com/storage/docs/uploading-objects#storage-upload-object-python
    """
    # # WORKAROUND to prevent timeout for files > 6 MB on 800 kbps upload speed.
    # # (Ref: https://github.com/googleapis/python-storage/issues/74)
    # storage.blob._MAX_MULTIPART_SIZE = 5 * 1024 * 1024  # 5 MB
    # storage.blob._DEFAULT_CHUNKSIZE = 5 * 1024 * 1024  # 5 MB

    client = storage.Client().from_service_account_json("/Users/ying/pipeline/kestra-sandbox-486603-287017c981ef.json")
    bucket = client.bucket(bucket)
    blob = bucket.blob(object_name)
    blob.upload_from_filename(local_file)

# Modify the function definition to accept a months parameter so we can specify exactly how many months to process
def web_to_gcs(year, service,months=12):
    for i in range(months):
        
        # sets the month part of the file_name string
        month = '0'+str(i+1)
        month = month[-2:]

        # csv file_name
        file_name = f"{service}_tripdata_{year}-{month}.csv.gz"

        # 1. download it using requests via a pandas df
        request_url = f"{init_url}{service}/{file_name}"
        r = requests.get(request_url)
        open(file_name, 'wb').write(r.content)
        print(f"Local: {file_name}")

        # 2. read it back into a parquet file
        df = pd.read_csv(file_name, compression='gzip')
        file_name = file_name.replace('.csv.gz', '.parquet')
        df.to_parquet(file_name, engine='pyarrow')
        print(f"Parquet: {file_name}")

        # 3. upload it to gcs 
        upload_to_gcs(BUCKET, f"{service}/{file_name}", file_name)
        print(f"GCS: {service}/{file_name}")
       
       # 4. delete the files after they are uploaded to GCS to free storage on device
        if os.path.exists(file_name):
            os.remove(file_name)
        if os.path.exists(parquet_name):
            os.remove(parquet_name)
        print(f"Cleaned up local files for {month}/{year}")


web_to_gcs('2019', 'green')
web_to_gcs('2020', 'green')
web_to_gcs('2024', 'yellow', months=6)
# web_to_gcs('2019', 'yellow')
# web_to_gcs('2020', 'yellow')
# web_to_gcs('2024','yellow', 1-6 month)
