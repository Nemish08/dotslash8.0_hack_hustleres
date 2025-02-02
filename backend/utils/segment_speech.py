from groq import Groq
from dotenv import load_dotenv
load_dotenv()

def segment_speech(uuid):
    groq = Groq(max_retries = 3)
    filename = f'speech/{uuid}_script.mp3'

    try:
        with open(filename, 'rb') as file:
            transcripton = groq.audio.transcriptions.create(
                file = (filename, file.read()),
                model = 'whisper-large-v3-turbo',
                response_format = 'verbose_json'
            )

            return { 'transcripton': transcripton, 'success': True }
    except Exception as e:
        return { 'msg': e, 'success': False }