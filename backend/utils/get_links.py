import requests
import json

def get_link_stock_videos(word, orientation):
    print(orientation, word)
    try:
        url = "https://pexels-js-api.vercel.app/api/pexels"

        payload = json.dumps({
            "query": word,
            "orientation": orientation
        })

        headers = {
            'Content-Type': 'application/json'
        }

        response = requests.request("POST", url, headers=headers, data=payload)
        print('done\n')
        return response.json()['videos']
    except Exception as e:
        print('seomthing', e)
        return []

