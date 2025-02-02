from flask import Flask, request, jsonify, Response
import json, os, time
from flask_cors import CORS
from utils import segment_speech
from utils.generate_script import generate_script, generate_script_options
from utils.generate_speech import tts_neets
from utils.segment_speech import segment_speech
from utils.extract_video_url import extract_video_url
from utils.download_videos import download_videos
from utils.merge_videos import merge_videos_in_directory, merge_videos_optimized
from utils.merge_audio import merge_audio
from utils.add_subtitles import add_subtitles_ffmpeg, add_subtitles_ffmpeg_as

from utils.imgs.generateImages import generate_images
from utils.imgs.mergeImages import create_video_from_images, create_video_from_images_web

from utils.imgs.download_web_images import download_web_images

from utils.save_video import upload_video_to_cloudinary

app = Flask(__name__)
CORS(app)

UPLOAD_FOLDER = 'uploads'
app.config["UPLOAD_FOLDER"] = UPLOAD_FOLDER

# status
@app.route('/api')
def status():
    return jsonify({'status': 'ok'})

# this one generates script
@app.route('/api/generate_script', methods=['POST'])
def generate_scrpt():
    data = request.get_json()
    prompt, uuid, web_search = data['prompt'], data['uuid'], data['web_search']

    script = generate_script(prompt, web_search)

    return jsonify({'script': script})

# this one generates multi scripts
@app.route('/api/generate_script_options', methods=['POST'])
def generate_scrpt_options():
    data = request.get_json()
    prompt, uuid = data['prompt'], data['uuid']

    scripts = generate_script_options(prompt)

    return scripts

# for marketing
@app.route('/api/marketing-own-images', methods=['POST'])
def marketing_images():
    json_data = request.form.get("json_data")  # Extract JSON as a string
    if json_data:
        json_data = json.loads(json_data)  # Convert to dictionary
    else:
        json_data = {}

    uuid = request.form.get("uuid")

    # Check if images are present
    if 'images' not in request.files:
        return jsonify({'error': 'No images found'}), 400

    images = request.files.getlist('images') 
    # uuid = json_data.get('uuid')
    print('uuid :', uuid)

    print(images)

    folder_path = os.path.join(app.config['UPLOAD_FOLDER'], uuid)

    if not os.path.exists(folder_path):
        os.makedirs(folder_path)

    saved_files = []
    
    for img in images:
        if img.filename == '':
            continue  
        
        filename = f"{int(time.time())}_{img.filename}"
        file_path = os.path.join(folder_path, filename)

        img.save(file_path)  
        saved_files.append(file_path)

    return jsonify({
        'message': 'Images uploaded successfully',
        'uuid': uuid,
        'saved_files': saved_files
    })

# generate video on the uploaded images
@app.route('/api/generate_video_own_images', methods=['POST'])
def generate_video_own_images():
    data = request.get_json()
    uuid, orientation, voice_id, style, script = data['uuid'], data['orientation'], data['voice_id'], data['style'], data['script']

    def generate_stream():
        data = {
            'progress': 0,
            'msg': 'Generating speech',
            'done': False
        }
        yield json.dumps(data) + '\n'

        # generate speech
        speech = generate_speech(script, voice_id, style)
        print(speech, '\n\n')

        data = {
            'progress': 1,
            'msg': f'Generated speech',
            'done': False,
        }
        yield json.dumps(data) + '\n'

        # segment speech
        segments = segment_speech(speech, orientation)
        print(segments, '\n\n')

        data = {
            'progress': 2,
            'msg': f'Segmented speech',
            'done': False,
        }
        yield json.dumps(data) + '\n'
        segments = segments['transcripton'].segments

        # create video
        video = create_video_from_segments(segments)
        print(video, '\n\n')

        data = {
            'progress': 3,
            'msg': f'Created video',
            'done': True,
        }
        yield json.dumps(data) + '\n'

@app.route('/api/generate_web_img', methods=['POST'])
def generate_web_img():
    data = request.get_json()
    prompt, script, uuid, orientation, voice_id, style = data['prompt'], data['script'], data['uuid'], data['orientation'], data['voice_id'], data['style']

    def generate_stream():
        data = {
            'progress': 0,
            'msg': f'Generating speech',
            'done': False
        }
        yield json.dumps(data) + '\n'

        speech = tts_neets(uuid, script, voice_id)

        data = {
            'progress': 1,
            'msg': f'Segmenting speech',
            'done': False,
        }
        yield json.dumps(data) + '\n'

        segments = segment_speech(uuid)
        print(segments, '\n\n')

        data = {
            'progress': 2,
            'msg': f'Downloading video',
            'done': False,
        }
        yield json.dumps(data) + '\n'
        segments = segments['transcripton'].segments

        # download images
        final_paths = download_web_images(prompt, segments, uuid)
        print('\n\n----------------------IMGDIR----------------------\n\n', final_paths)

        data = {
            'progress': 3,
            'msg': 'Merging downloaded web searched images',
            'done': True
        }
        yield json.dumps(data) + '\n'

        end_time = segments[-1]['end']

        # make video out of generated images
        image_duration_list = []
        for i in range(len(os.listdir(f'./images/{uuid}/'))):
            print('new image')
            # if ind != len(segments) - 1:
            #     duration = float(segments[ind + 1]['start'] - segment['start'])
            # else:
            #     duration = float(segment['end'] - segment['start'])
            duration = float(end_time / len(os.listdir(f'./images/{uuid}/')))
            print(duration)
            image_duration_list.append((final_paths[i], duration))

        time_file_name = time.time()

        if not os.path.exists(f'./output/{uuid}/'):
            os.mkdir(f'./output/{uuid}/')
        create_video_from_images_web(image_duration_list, f'./output/{uuid}/{uuid}_{time_file_name}.mp4')

        data = {
            'progress': 5,
            'msg': f'Merging audio',
            'done': False
        }
        yield json.dumps(data) + '\n'

        merge_audio(f'./output/{uuid}/{uuid}_{time_file_name}.mp4', f'speech/{uuid}_script.mp3', f'./output/{uuid}/{uuid}_final_{time_file_name}.mp4')

        data = {
            'progress': 6,
            'msg': f'Merging subtitles',
            'done': False
        }
        yield json.dumps(data) + '\n'

        # add_subtitles_ffmpeg(f'./output/{uuid}/{uuid}_final_{time_file_name}.mp4', segments, f'./output/{uuid}/{uuid}_subtitle_final_{time_file_name}.mp4', uuid)
        add_subtitles_ffmpeg_as(f'./output/{uuid}/{uuid}_final_{time_file_name}.mp4', segments, f'./output/{uuid}/{uuid}_subtitle_final_{time_file_name}.mp4', uuid, style)

        os.remove(f'./output/{uuid}/{uuid}_final_{time_file_name}.mp4')
        os.remove(f'./output/{uuid}/{uuid}_{time_file_name}.mp4')
        for filename in os.listdir(f'./images/{uuid}/'):
            os.remove(f'./images/{uuid}/{filename}')
        
        data = {
            'progress': 7,
            'msg': f'Uploading video',
            'done': False
        }
        yield json.dumps(data) + '\n'

        url = upload_video_to_cloudinary(f'./output/{uuid}/{uuid}_subtitle_final_{time_file_name}.mp4', uuid)

        data = {
            'progress': 8,
            'msg': f'Video generated successfully',
            'done': True,
            'url': url
        }
        yield json.dumps(data) + '\n'
        os.remove(f'speech/{uuid}_script.mp3')

        yield json.dumps(data) + '\n'

    return Response(generate_stream(), mimetype='application/json', headers={'Connection': 'keep-alive'})
 


@app.route('/api/generate_img_content', methods=['POST'])
def generate_img_content():
    data = request.get_json()
    prompt, script, uuid, orientation, voice_id, style = data['prompt'], data['script'], data['uuid'], data['orientation'], data['voice_id'], data['style']

    def generate_stream():
        # data = {
        #     'progress': 1,
        #     'msg': f'Generating script',
        #     'done': False,
        # }
        # yield json.dumps(data) + '\n'

        # script = generate_script(prompt)
        # print(script, '\n\n')

        data = {
            'progress': 1,
            'msg': f'Generating speech from script',
            'done': False,
            'script': script
        }
        yield json.dumps(data) + '\n'

        # Generate the speech
        res = tts_neets(uuid, script, voice_id)
        if not res['success']:
            data = {
                'progress': 1,  
                'msg': f'Error generating speech : {res["msg"]}',
                'done': True
            }
            yield json.dumps(data) + '\n'
            return jsonify(data)

        data = {
            'progress': 2,
            'msg': f'Segmenting speech',
            'done': False
        }
        yield json.dumps(data) + '\n'

        segments = segment_speech(uuid)
        if not segments['success']:
            data = {
                'progress': 2,
                'msg': f'Error segmenting speech : {segments["msg"]}',
                'done': True
            }
        segments = segments['transcripton'].segments
        print(segments, '\n\n')

        data = {
            'progress': 3,
            'msg': f'Generating images',
            'done': False
        }

        generate_images(prompt, segments, uuid, orientation, style)
        data = {
            'progress': 4,
            'msg': f'Images generated',
            'done': True
        }
        yield json.dumps(data) + '\n'
        print('Given prompt:', prompt, '\n\n')

        # make video out of generated images
        image_duration_list = []
        for ind, segment in enumerate(segments):
            if ind != len(segments) - 1:
                duration = float(segments[ind + 1]['start'] - segment['start'])
            else:
                duration = float(segment['end'] - segment['start'])
            image_duration_list.append((f'./images/{uuid}/{ind}.png', duration))

        time_file_name = time.time()

        if not os.path.exists(f'./output/{uuid}/'):
            os.mkdir(f'./output/{uuid}/')
        create_video_from_images(image_duration_list, f'./output/{uuid}/{uuid}_{time_file_name}.mp4')

        data = {
            'progress': 5,
            'msg': f'Merging audio',
            'done': False
        }
        yield json.dumps(data) + '\n'

        merge_audio(f'./output/{uuid}/{uuid}_{time_file_name}.mp4', f'speech/{uuid}_script.mp3', f'./output/{uuid}/{uuid}_final_{time_file_name}.mp4')

        data = {
            'progress': 6,
            'msg': f'Merging subtitles',
            'done': False
        }
        yield json.dumps(data) + '\n'

        # add_subtitles_ffmpeg(f'./output/{uuid}/{uuid}_final_{time_file_name}.mp4', segments, f'./output/{uuid}/{uuid}_subtitle_final_{time_file_name}.mp4', uuid)
        add_subtitles_ffmpeg_as(f'./output/{uuid}/{uuid}_final_{time_file_name}.mp4', segments, f'./output/{uuid}/{uuid}_subtitle_final_{time_file_name}.mp4', uuid, style)

        os.remove(f'./output/{uuid}/{uuid}_final_{time_file_name}.mp4')
        os.remove(f'./output/{uuid}/{uuid}_{time_file_name}.mp4')
        for filename in os.listdir(f'./images/{uuid}/'):
            os.remove(f'./images/{uuid}/{filename}')
        
        data = {
            'progress': 7,
            'msg': f'Uploading video',
            'done': False
        }
        yield json.dumps(data) + '\n'

        url = upload_video_to_cloudinary(f'./output/{uuid}/{uuid}_subtitle_final_{time_file_name}.mp4', uuid)

        data = {
            'progress': 8,
            'msg': f'Video generated successfully',
            'done': True,
            'url': url
        }
        yield json.dumps(data) + '\n'
        os.remove(f'speech/{uuid}_script.mp3')

    return Response(generate_stream(), mimetype='application/json', headers={'Connection': 'keep-alive'})


# below is being used to generate once the script is generated (stock videos)
@app.route('/api/generate_2', methods=['POST'])
def generate2():
    data = request.get_json()
    script, uuid, orientation, voice_id, style = data['script'], data['uuid'], data['orientation'], data['voice_id'], data['style']

    def generate_stream():
        data = {
            'progress': 1,
            'msg': f'Generating speech from script',
            'done': False,
            'script': script
        }
        yield json.dumps(data) + '\n'

        # Generate the speech
        res = tts_neets(uuid, script, voice_id)
        if not res['success']:
            data = {
                'progress': 2,  
                'msg': f'Error generating speech : {res["msg"]}', 
                'done': True
            }
            yield json.dumps(data) + '\n'
            return jsonify(data)

        data = {
            'progress': 3,
            'msg': f'Segmenting speech',
            'done': False
        }
        yield json.dumps(data) + '\n'

        # Segment the speech
        segments = segment_speech(uuid)
        if not segments['success']:
            data = {
                'progress': 4,  
                'msg': f'Error segmenting speech : {res["msg"]}',
                'done': True
            }
            yield json.dumps(data) + '\n'
            return jsonify(data)
        segments = segments['transcripton'].segments
        print(segments, '\n\n')

        data = {
            'progress': 4,
            'msg': f'Searching for search words to grab videos',
            'done': False
        }
        yield json.dumps(data) + '\n'

        # Extract the video urls
        # TODO: make it more efficient    
        video_urls = extract_video_url(segments, orientation)
        if video_urls == []:
            data = {
                'progress': 5,  
                'msg': f'Error searching for search words : {res["msg"]}',
                'done': True
            }
            yield json.dumps(data) + '\n'
            return jsonify(data)
        print('\n\n\n', video_urls)

        data = {
            'progress': 5,
            'msg': f'Downloading and Trimming videos',
            'done': False
        }
        yield json.dumps(data) + '\n'

        # Download and trim videos
        video_names = download_videos(video_urls, uuid, orientation)
        print('\n\n\n', video_names, '\n\n')

        data = {
            'progress': 6,
            'msg': f'Merging trimmed videos',
            'done': False
        }
        yield json.dumps(data) + '\n'

        # merge_videos_in_directory(video_names, f'videos/{uuid}/merged', uuid)
        merge_videos_optimized(video_names, f'videos/{uuid}/merged.mp4', uuid)
        # trim_video_optimized(orientation, f'videos/{uuid}/merged.mp4', f'videos/{uuid}/trimmed.mp4', 10.0, 0)

        # Send the script
        data = {
            'progress': 7,
            'msg': f'Merging audio',
            'done': False
        }
        yield json.dumps(data) + '\n'

        # Merge audio
        merge_audio(f'videos/{uuid}/merged.mp4', f'speech/{uuid}_script.mp3', f'videos/{uuid}/final.mp4')

        data = {
            'progress': 8,
            'msg': f'Adding subtitles',
            'done': False
        }
        yield json.dumps(data) + '\n'

        time_filename = time.time()

        # Add subtitles
        if not os.path.exists(f'videos/{uuid}_final/'):
            os.mkdir(f'videos/{uuid}_final/')
        # add_subtitles_ffmpeg(f'videos/{uuid}/final.mp4', segments, f'videos/{uuid}_final/final-sub-{time_filename}.mp4', uuid)
        add_subtitles_ffmpeg_as(f'videos/{uuid}/final.mp4', segments, f'videos/{uuid}_final/final-sub-{time_filename}.mp4', uuid, style)

        data = {
            'progress': 9,
            'msg': f'Uploading video',
            'done': False
        }
        yield json.dumps(data) + '\n'
        # os.rmdir(f'videos/{uuid}/')
        url = upload_video_to_cloudinary(f'videos/{uuid}_final/final-sub-{time_filename}.mp4', uuid)
        print('\n\nURL:', url)
        os.remove(f'speech/{uuid}_script.mp3')
        os.remove(f'videos/{uuid}/final.mp4')
        os.remove(f'videos/{uuid}/merged.mp4')
        # for filename in os.listdir(f'videos/{uuid}/'):
        #     print(filename)
        #     os.remove(f'videos/{uuid}/{filename}')

        data = {
            'progress': 10,
            'msg': f'Video uploaded successfully',
            'done': True,
            'url': url
        }
        yield json.dumps(data) + '\n'
    
    return Response(generate_stream(), mimetype='application/json', headers={'Connection': 'keep-alive'})

# below one is just for testing purpose
@app.route('/api/generate', methods=['POST'])
def generate():
    data = request.get_json()
    prompt, uuid, orientation = data['prompt'], data['uuid'], data['orientation']

    def generate_stream():
        data = {
            'progress': 0,
            'msg': f'Generating script on : {prompt}',
            'done': False
        }
        yield json.dumps(data) + '\n'

        # Generate the script
        script = generate_script(prompt)
        data = {
            'progress': 1,
            'msg': f'Generating speech from script',
            'done': False,
            'script': script
        }
        yield json.dumps(data) + '\n'

        # Generate the speech
        res = tts_neets(uuid, script)
        if not res['success']:
            data = {
                'progress': 2,  
                'msg': f'Error generating speech : {res["msg"]}',
                'done': True
            }
            yield json.dumps(data) + '\n'
            return jsonify(data)

        data = {
            'progress': 3,
            'msg': f'Segmenting speech',
            'done': False
        }
        yield json.dumps(data) + '\n'

        # Segment the speech
        segments = segment_speech(uuid)
        if not segments['success']:
            data = {
                'progress': 4,  
                'msg': f'Error segmenting speech : {res["msg"]}',
                'done': True
            }
            yield json.dumps(data) + '\n'
            return jsonify(data)
        segments = segments['transcripton'].segments
        print(segments, '\n\n')

        data = {
            'progress': 4,
            'msg': f'Searching for search words to grab videos',
            'done': False
        }
        yield json.dumps(data) + '\n'

        # Extract the video urls
        # TODO: make it more efficient    
        video_urls = extract_video_url(segments, orientation)
        if video_urls == []:
            data = {
                'progress': 5,  
                'msg': f'Error searching for search words : {res["msg"]}',
                'done': True
            }
            yield json.dumps(data) + '\n'
            return jsonify(data)
        print('\n\n\n', video_urls)

        data = {
            'progress': 5,
            'msg': f'Downloading and Trimming videos',
            'done': False
        }
        yield json.dumps(data) + '\n'

        # Download and trim videos
        video_names = download_videos(video_urls, uuid, orientation)
        print('\n\n\n', video_names, '\n\n')

        data = {
            'progress': 6,
            'msg': f'Merging trimmed videos',
            'done': False
        }
        yield json.dumps(data) + '\n'

        # merge_videos_in_directory(video_names, f'videos/{uuid}/merged', uuid)
        merge_videos_optimized(video_names, f'videos/{uuid}/merged.mp4', uuid)
        # trim_video_optimized(orientation, f'videos/{uuid}/merged.mp4', f'videos/{uuid}/trimmed.mp4', 10.0, 0)

        # Send the script
        data = {
            'progress': 7,
            'msg': f'Merging audio',
            'done': True
        }
        yield json.dumps(data) + '\n'

        merge_audio(f'videos/{uuid}/merged.mp4', f'speech/{uuid}_script.mp3', f'videos/{uuid}/final.mp4')

        data = {
            'progress': 8,
            'msg': f'Adding subtitles',
            'done': True
        }
        yield json.dumps(data) + '\n'

        time_filename = time.time()

        add_subtitles_ffmpeg(f'videos/{uuid}/final.mp4', segments, f'videos/{uuid}/final-sub-{time_filename}.mp4', uuid)

        data = {
            'progress': 9,
            'msg': f'Saving video',
            'done': False
        }
        yield json.dumps(data) + '\n'

        url = upload_video_to_cloudinary(f'videos/{uuid}_final/final-sub-{time_filename}.mp4', uuid)

        data = {
            'progress': 9,
            'msg': f'Video generated successfully',
            'done': True,
            'url': url
        }
        yield json.dumps(data) + '\n'

    
    return Response(generate_stream(), mimetype='application/json', headers={'Connection': 'keep-alive'})

        # data = {
        #     'progress': 100,
        #     'msg': f'Script sent on : {prompt}',
        #     'done': True
        # }
        # yield json.dumps(data) + '\n'

    

if __name__ == '__main__':
    app.run(debug=True)