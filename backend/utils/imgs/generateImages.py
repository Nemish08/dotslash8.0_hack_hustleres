import requests, os, base64, time
from groq import Groq
from dotenv import load_dotenv
load_dotenv()

API_BASE_URL = "https://api.cloudflare.com/client/v4/accounts/b7534c11126a1a2f5b342d4c352dbcdf/ai/run/"
headers = {"Authorization": "Bearer NZLXUdUu_0k38UIE9jNFxMyb6zI3GgDXhsFUSO_x"}

def run(model, prompt):
    input = { "prompt": prompt, "steps": 2 }
    response = requests.post(f"{API_BASE_URL}{model}", headers=headers, json=input)
    return response.json()['result']

# out = run("@cf/black-forest-labs/flux-1-schnell", "boy running with a dog")
# print(out)

def download_base64_image(base64_url, save_path):
    try:
        if "," in base64_url:
            base64_data = base64_url.split(",")[1]
        else:
            base64_data = base64_url

        image_data = base64.b64decode(base64_data)

        save_dir = os.path.dirname(save_path)
        if save_dir and not os.path.exists(save_dir):
            os.makedirs(save_dir)

        with open(save_path, "wb") as img_file:
            img_file.write(image_data)

        print(f"image successfully saved at: {save_path}")
        return save_path

    except Exception as e:
        print(f"error saving Base64 image: {e}")
        return None

# output = run("@cf/black-forest-labs/flux-1-schnell", "boy running with a dog")
# print(output)

def generate_images(prompt, segments, user_uuid, orientation, style):
    groq = Groq(max_retries = 3)

    print('\n\n--------------------------GIVEN PROMPT: ', prompt, '--------------------------\n\n')

    for ind, segment in enumerate(segments):
        try:
            img_prompt = groq.chat.completions.create(
                model = 'llama3-8b-8192',
                messages = [
                    {
                        "role": "system",
                        "content": "Your task is to generate a detailed and enhanced prompt for generating images from given text/sentence by the user. The prompt should be specific, informative, and tailored to the user's input. The generated prompt should guide the image-generation model in generating high-quality images that capture the essence of the input sentence. The user will also provide the style of the image, whether it should be realistic, cartoonish, or any other style. The generated prompt should be as detailed and specific as possible, considering the user's input and the desired style of the image. The output must only contain the prompt and no other text or punctuation or else you get penalized."
                    },
                    {
                        "role": "user",
                        "content": f"Main context on which the image should be generated: {prompt}\nInput sentence from user:\n{segment['text']}\nStyle: {style}"
                    }
                ],
                temperature = 0.4,
                max_tokens = 500,
                top_p = 1,
                stop = None,
            )

            img_prompt = img_prompt.choices[0].message.content

            print(ind, ':', img_prompt, '\n')

            while True:
                output = run("@cf/black-forest-labs/flux-1-schnell", img_prompt)

                if output and output['image']:
                    download_base64_image(output['image'], f'images/{user_uuid}/{ind}.png')
                    break
                
                print('sleeping for 4 seconds')
                time.sleep(4)



            # base_url = "https://image.pollinations.ai/prompt/"
            # width = 512
            # height = 512

            # if orientation == 'landscape':
            #     width = 1024
            #     height = 512
            # elif orientation == 'portrait':
            #     width = 512
            #     height = 1024
            # else:
            #     width = 512
            #     height = 512

            # params = {
            #     'width': width,
            #     'height': height,
            #     'nologo': 'true',
            #     'private': 'true',
            #     'enhance': 'true'
            # }

            # url = f"{base_url}{requests.utils.quote(img_prompt)}"

            # response = requests.get(url, params=params, timeout=(10, 600))
            # response.raise_for_status()

            # if not os.path.exists(f'images/{user_uuid}'):
            #     os.makedirs(f'images/{user_uuid}')
            # # Save the image
            # with open(f'images/{user_uuid}/{ind}.png', 'wb') as file:
            #     file.write(response.content)
            print(f"Image successfully generated and saved as {ind}\n\n")
        except Exception as e: 
            print(e)