import requests
from dotenv import load_dotenv
load_dotenv()

def tts_neets(uuid, script, voice_id):
    try:
        response = requests.request(
            method="POST",
            url="https://api.neets.ai/v1/tts",
            headers={
                "Content-Type": "application/json",
                "X-API-Key": "YOUR_API_KEY"
            },
            json={
                "text": script,
                # "voice_id": "us-male-1",
                "voice_id": voice_id,
                "params": {
                    "model": "style-diff-500"
                }
            }
        )

        with open(f"speech/{uuid}_script.mp3", "wb") as f:
            f.write(response.content)

        return { "success": True, "msg": "sucess" }
    except Exception as e:
        return { "success": False, "msg": e }