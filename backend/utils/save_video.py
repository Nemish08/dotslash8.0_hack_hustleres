from google.resumable_media.requests import upload
from pymongo import MongoClient
import gridfs

import cloudinary, cloudinary.uploader, cloudinary.api, os
from datetime import datetime

import requests
import time

def get_epoch_plus_20min():
    current = int(time.time() * 1000)
    future = current + (20 * 60 * 1000)
    return future

def generate_link(file):
    url = "https://0x0.st"
    files = { 'file': open(file, 'rb'), 'expires': get_epoch_plus_20min() }
    response = requests.post(url, files=files)
    return response.text.strip()  

def upload_video_to_cloudinary(video_path, folder=None):
    try:
        cloudinary.config(
            cloud_name = "djc4fwyrc",
            api_key = "912755849452169",
            api_secret = "j1wdGvP1IQLISwDDtYOOB3YeCGI"
        )
        
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        filename = os.path.splitext(os.path.basename(video_path))[0]
        public_id = f"{timestamp}_{filename}"
        
        if folder:
            public_id = f"{folder}/{public_id}"
        
        print("Uploading video... This may take a while depending on the file size.")
        
        upload_result = cloudinary.uploader.upload(
            video_path,
            resource_type="video",
            public_id=public_id,
            chunk_size=6000000, 
        )
        
        print("Video uploaded successfully!")
        
        video_url = upload_result['secure_url']
        
        return video_url
    
    except Exception as e:
        print(f"Error uploading video: {str(e)}")
        raise


def mongo_connect():
    try:
        conn = MongoClient(host='localhost', port=27017)
        print("Mongo connected successfully:", conn)
    except Exception as e:
        print(e)

def save_video(path, video_name):
    try:
        video_location = path
        video = open(video_location, 'rb')
        data = video.read()
        fs = gridfs.GridFS(conn['vidAi'])
        fs.put(data, filename=video_name)
        print("Video saved successfully")
        return True
    except Exception as e:
        print(e)
        return False