from turtle import down
import requests, json
from groq import Groq
import os
from urllib.parse import urlparse
from dotenv import load_dotenv
load_dotenv()

def download_web_images(prompt, segments, user_uuid):
    print(f"🔍 Searching images for: {prompt}")

    counter = 0
    page = 1
    res_counter = 0
    response = []

    final_paths = []

    img_dir = f"images/{user_uuid}"
    if not os.path.exists(img_dir):
        os.makedirs(img_dir)  

    while counter < len(segments):
        if res_counter >= len(response):
            url = "https://google.serper.dev/images"
            payload = json.dumps({"q": prompt, "page": page})
            headers = {
                'X-API-KEY': 'db67eccf94ca43c6dcdf803fab56a170135774ac',
                'Content-Type': 'application/json'
            }

            try:
                response = requests.post(url, headers=headers, data=payload).json()
                response = response.get('images', [])
                if not response:
                    print("No more images found.")
                    break  
            except Exception as e:
                print(f"Error fetching image results: {e}")
                break

            page += 1 

        img_url = response[res_counter]['imageUrl']
        res_counter += 1 

        try:
            parsed_url = urlparse(img_url)
            ext = os.path.splitext(parsed_url.path)[-1].lower()

            if not ext or ext not in ['.jpg', '.jpeg', '.png', '.gif', '.webp']:
                head_response = requests.head(img_url, timeout=10)
                head_response.raise_for_status()
                content_type = head_response.headers.get("Content-Type", "")
                ext_map = {
                    "image/jpeg": ".jpg",
                    "image/png": ".png",
                    "image/gif": ".gif",
                    "image/webp": ".webp"
                }
                ext = ext_map.get(content_type, ".jpg")  

            img_response = requests.get(img_url, timeout=(10, 600))
            img_response.raise_for_status()

            img_path = f"{img_dir}/{counter}{ext}"
            final_paths.append('./' + img_path)
            with open(img_path, 'wb') as file:
                file.write(img_response.content)

            print(f"Image saved as {img_path}")
            counter += 1  

        except Exception as e:
            print(f"Error downloading {img_url}: {e}")

    return final_paths

# download_web_images("dotslash hackathon", [1, 2, 3], "onqoasalsm")

# def download_web_images(prompt, segments, user_uuid):
#     print(f"🔍 Searching images for: {prompt}")

#     counter = 0
#     page = 1
#     res_counter = 0
#     response = []

#     while counter < len(segments):
#         if res_counter >= len(response):
#             url = "https://google.serper.dev/images"
#             payload = json.dumps({"q": prompt, "page": page})
#             headers = {
#                 'X-API-KEY': 'db67eccf94ca43c6dcdf803fab56a170135774ac',
#                 'Content-Type': 'application/json'
#             }

#             try:
#                 response = requests.post(url, headers=headers, data=payload).json()
#                 response = response.get('images', [])
#                 if not response:
#                     print("No more images found.")
#                     break 
#             except Exception as e:
#                 print(f"⚠️ Error fetching image results: {e}")
#                 break

#             page += 1 

#         img_url = response[res_counter]['imageUrl']
#         res_counter += 1 

#         try:
#             ext = None
#             if "." in img_url.split("/")[-1]: 
#                 ext = img_url.split(".")[-1].split("?")[0]
#                 if ext.lower() not in ['jpg', 'jpeg', 'png', 'gif', 'webp']:
#                     ext = None 

#             if not ext:
#                 head_response = requests.head(img_url, timeout=10)
#                 head_response.raise_for_status()
#                 content_type = head_response.headers.get("Content-Type", "")
#                 ext_map = {
#                     "image/jpeg": "jpg",
#                     "image/png": "png",
#                     "image/gif": "gif",
#                     "image/webp": "webp"
#                 }
#                 ext = ext_map.get(content_type, "jpg")  # Default to JPG if unknown

#             img_response = requests.get(img_url, timeout=(10, 600))
#             img_response.raise_for_status()

#             img_dir = f'./images/{user_uuid}'
#             os.makedirs(img_dir, exist_ok=True)

#             img_path = f"{img_dir}/{counter}.{ext}"
#             with open(img_path, 'wb') as file:
#                 file.write(img_response.content)

#             print(f"✅ Image saved as {img_path}")
#             counter += 1  

#         except Exception as e:
#             print(f"⚠️ Error downloading {img_url}: {e}")

# def download_web_images(prompt, segments, user_uuid):
#     print('prompt:', prompt)
#     try:
#         url = "https://google.serper.dev/images"
#         payload = json.dumps({
#             "q": prompt
#         })
#         headers = {
#             'X-API-KEY': 'db67eccf94ca43c6dcdf803fab56a170135774ac',
#             'Content-Type': 'application/json'
#         }

#         response = requests.request("POST", url, headers=headers, data=payload)
#         print(response.json())

#         response = response.json()['images']

#         print('response: ', response)
#         print('length of segment: ', len(segments))

#         counter = 0
#         page = 1
#         res_counter = 0

#         for ind in range(len(segments)):
#             while True:
#                 try:
#                     if res_counter >= len(response):
#                         page += 1
#                         url = "https://google.serper.dev/images"
#                         payload = json.dumps({
#                             "q": prompt,
#                             "page": page
#                         })
#                         headers = {
#                             'X-API-KEY': 'db67eccf94ca43c6dcdf803fab56a170135774ac',
#                             'Content-Type': 'application/json'
#                         }

#                         response = requests.request("POST", url, headers=headers, data=payload)
#                         print(response.json())

#                         response = response.json()['images']
                        
#                     url = response[res_counter]['imageUrl']

#                     if url.endswith('.jpg') or url.endswith('.png') or url.endswith('.jpeg'):
#                         response_ = requests.get(url, timeout=(10, 600))
#                         response_.raise_for_status()

#                         if not os.path.exists(f'images/{user_uuid}'):
#                             os.makedirs(f'images/{user_uuid}')

#                         with open(f'images/{user_uuid}/{counter}.png', 'wb') as file:
#                             file.write(response_.content)
                        
#                         counter += 1
#                         res_counter += 1
#                         print(f"Image successfully generated and saved as {counter-1}\n\n")
#                         break

#                     else: res_counter += 1

#                 except Exception as e:
#                     print(e)
#                     res_counter += 1

#     except Exception as e:
#         print(e)

# download_web_images("deepskeep ai model", [{"text": "this"}, {"text": "this"}, {"text": "this"}, {"text": "this"}, {"text": "this"}, {"text": "this"}, {"text": "this"}], "onqoasalsm")