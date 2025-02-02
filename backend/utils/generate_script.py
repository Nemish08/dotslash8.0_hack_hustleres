from groq import Groq
import json
from dotenv import load_dotenv
import json, os, requests
load_dotenv()

def generate_script_options(prompt: str):
    groq = Groq(max_retries = 3)

    completion = groq.chat.completions.create(
        model="llama3-8b-8192",
        messages=[
            {
                "role": "system",
                "content": "You are an AI scriptwriter specializing in generating concise and engaging Marketing Advertisement Shorts scripts. Generate a script in less than 60 words, written in the third person as if a narrator is telling a short story. The script should follow a storytelling format, such as: 'This product has unique features.... ' Avoid first-person perspectives, direct dialogues, or personal expressions. Output only the script text, with no explanations or formatting instructions. You have to generate 4 versions of the script and the final output must be in JSON format. The JSON format should looks like this: {'scripts': ['script1', 'script2', 'script3', 'script4']}"
            },
            {
                "role": "user",
                "content": prompt
            },
        ],
        temperature=0.6,
        max_tokens=1800,
        response_format={"type": "json_object"},
        top_p=1,
        stop=None,
    )

    return json.loads(completion.choices[0].message.content)['scripts']
    
generate_script_options("black dress")
def generate_script(prompt: str, web_search: bool = False):
    groq = Groq(max_retries = 3)

    if not web_search:
        completion = groq.chat.completions.create(
            model="llama3-8b-8192",
            messages=[
                {
                    "role": "system",
                    # "content": "You are a creative scriptwriter who generates engaging short scripts (20-30 seconds) based on user prompts. The script should follow this structure: Hook (First 5 seconds): Start with a surprising fact, question, or bold statement to grab attention. Main Content (15-20 seconds): Provide interesting details, explanations, or a short narrative related to the topic. Keep it concise and engaging. Conclusion (Last 5 seconds): Wrap up with a twist, thought-provoking idea, or call to action to maintain audience interest. If no prompt is provided, suggest an interesting topic yourself (e.g., science facts, history, mysteries, tech innovations, or inspiring stories)."
                    "content": "You are an AI scriptwriter specializing in generating concise and engaging YouTube Shorts scripts. Generate a script in less than 60 words, written in the third person as if a narrator is telling a short story. The script should follow a storytelling format, such as: 'There was a boy named Elon. He was a genius boy...' Avoid first-person perspectives, direct dialogues, or personal expressions. Output only the script text, with no explanations or formatting instructions."
                    # "content": "You are a creative and captivating story/script writer, specializing in short, engaging scripts perfect for YouTube shorts or similar formats.\nYour task is to write brief, interesting, and visually compelling scripts without dialogue, scene numbers, or any action notes (e.g., no elements like '(background music)' or scene descriptions in parentheses).\nThe script should read like a fast-paced narrative that flows seamlessly from one thought to the next, delivering key points in a fun, energetic, and impactful way.\n\nRequirements:\n\nKeep it short, snappy, and packed with engaging information that captures attention from the start.\nOnly generate narrative text.\nNo dialogue, scene numbers, or action instructions in parentheses.\nAim for a dynamic and upbeat presentation style, delivering each line as if it’s a story unfolding quickly and vividly in the viewer’s mind.\n\nCreate scripts that feel lively, memorable, and perfectly tailored for short-form video content! No more than 100 words to be generated. The output must not contain any dialogue such as 'sure, here is the script for'. Only generate script text."
                },
                {
                    "role": "user",
                    "content": "Topic: " + prompt
                }
            ],
            temperature=0.5,
            max_tokens=1080,
            top_p=1,
            stop=None,
        )

        return completion.choices[0].message.content

    else:
        url = "https://google.serper.dev/search"
        payload = json.dumps({
            "q": prompt
        })
        headers = {
            'X-API-KEY': 'db67eccf94ca43c6dcdf803fab56a170135774ac',
            'Content-Type': 'application/json'
        }

        response = requests.request("POST", url, headers=headers, data=payload)

        web_content = ''

        print(response.json(), '\n\n')

        for result in response.json()['organic']:
            try:
                if result and result['title'] and result['snippet']:
                    web_content += result['title'] + '\n' + result['snippet'] + '\n\n'
            except:
                continue
            
        completion = groq.chat.completions.create(
            model="llama3-8b-8192",
            messages=[
                {
                    "role": "system",
                    "content": "Your task is to generate a content type/shorts type script based on the given topic and web content.\nYou are a creative and captivating story/script writer, specializing in short, engaging scripts perfect for YouTube shorts or similar formats.\nWrite script based on the given context and also add some of your stuff. Only give the script and no other explanation or instructions. Do not give script having things such as (intro), (background music), just give script in text. Also do not give things such as 'Title' in the script, only generate the script or else you will get penalty. There should also not be any timestamps or anything. Also do not give text such as : 'Here's a script for a YouTube shorts type content based on the given topic:'. The script should not be more than 60 words long."
                },
                {
                    "role": "user",
                    "content": "Web content: " + web_content + "\nTopic: " + prompt
                }
            ],
            temperature=0.5,
            max_tokens=1080,
            top_p=1,
            stop=None,
        )

        return completion.choices[0].message.content


# def generate_script(prompt: str) -> str:
#     url = "https://flow-api.mira.network/v1/flows/flows/jsamurai/content-script-generator?version=1.0.0"

#     payload = json.dumps({
#         "input": {
#             "user_prompt": prompt
#         }
#     })
#     headers = {
#         'content-type': 'application/json',
#         'miraauthorization': os.getenv('MIRA_API_KEY'),
#     }

#     response = requests.request("POST", url, headers=headers, data=payload)

#     print(response.json()['result'])
#     return response.json()['result']

