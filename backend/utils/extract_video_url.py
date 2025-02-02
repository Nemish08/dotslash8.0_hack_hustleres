import requests
from groq import BaseModel, Groq
from numpy import true_divide
from utils.get_links import get_link_stock_videos
from dotenv import load_dotenv
load_dotenv()
import time, math, random

class Segment(BaseModel):
    word: str
    start: int
    end: int

def extract_video_url(segments, orientation): 
    groq = Groq(max_retries = 3)

    search_words: list[Segment] = []

    for segment in segments:
        word = groq.chat.completions.create(
            model = 'llama-3.1-8b-instant',
            messages = [
                {
                    "role": "system",
                    "content": "Your task is to extract simple, commonly used keywords or phrases from sentences, prioritizing those most likely to match easily searchable stock videos. Focus on capturing the central action, object, or theme using basic, widely recognized words. Avoid complex or niche terms that may be hard to match with videos. Use simple, clear words like \"rocket\" instead of \"space shuttle,\" and ignore dates, proper nouns, and unnecessary descriptors unless essential to the meaning. Do not use quotation marks in the output.\n\nExamples:\nInput: In 2154, the once-blue skies turned a hazy gray.\nOutput: gray sky\nInput: Cities floated on water, a desperate attempt to escape the rising tides.\nOutput: floating city\nInput: Robots worked tirelessly, harvesting the last of the world's resources.\nOutput: robots working\nInput: A lone astronaut, drifting through space, gazed back at the dying planet.\nOutput: astronaut in space\n\nGenerate simple, relevant keywords for each new sentence provided.\nThe output must only be words, no other text or punctuation or else you get penalized! The output words should not be more than 2."
                },
                {
                    "role": "user",
                    "content": f"Input sentence:\n{segment['text']}"
                }
            ],
            temperature = 0.4,
            max_tokens = 100,
            top_p = 1,
            stop = None,
        )

        segment = {
            'word': word.choices[0].message.content,
            'start': segment['start'],
            'end': segment['end']
        }
        search_words.append(segment)
        

    print('SEARCH WORDS\n\n', search_words, '\n\n\n\n')
    urls = []
    for word in search_words:
        w = word['word']
        print('word to be searched:', w)
        time.sleep(2)
        video_urls = get_link_stock_videos(w, orientation)

        counter = 0
        flag = False

        while not flag and counter < 5:
            video_url = video_urls[int(math.floor(random.random() * len(video_urls)))]
            if video_url:
                url = ''
                for video_file in video_url['video_files']:
                    # for video_file in video['video_files']:
                    if orientation == 'landscape' and video_file['width'] == 960 and video_file['height'] == 540:
                        url = video_file['link']
                        print(url)
                        res = requests.head(url, allow_redirects=True)
                        if res.status_code == 200:
                            flag = True
                        break
                    elif orientation == 'portrait' and video_file['width'] == 540 and video_file['height'] == 960:
                        url = video_file['link']
                        print(url)
                        res = requests.head(url, allow_redirects=True)
                        if res.status_code == 200:
                            flag = True
                        break
                    elif orientation == 'square' and video_file['width'] == 540 and video_file['height'] == 540:
                        url = video_file['link']
                        print(url)
                        res = requests.head(url, allow_redirects=True)
                        if res.status_code == 200:
                            flag = True
                        break

                if flag:
                    url_data = {
                        'start': word['start'],
                        'end': word['end'],
                        'video_url': url
                    }
                    urls.append(url_data)
                counter += 1

    return urls

