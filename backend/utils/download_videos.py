import uuid, requests, os
# from moviepy.video.io.VideoFileClip import VideoFileClip
from moviepy.editor import VideoFileClip
import ffmpeg, traceback
from dotenv import load_dotenv
load_dotenv()

# def trim_video_ffmpeg(input_path, output_path, end_time):
#     try:
#         # Fully resolve and normalize paths
#         input_path = os.path.abspath(os.path.normpath(input_path))

#         # Verify input file exists
#         if not os.path.exists(input_path):
#             print(f"Input file does not exist: {input_path}")
#             return False

#         # Verify input is a file
#         if not os.path.isfile(input_path):
#             print(f"Input path is not a file: {input_path}")
#             return False

#         # Ensure output directory exists
#         output_dir = os.path.dirname(output_path)
#         os.makedirs(output_dir, exist_ok=True)

#         (
#             ffmpeg
#             .input(input_path, ss=0, t=end_time)
#             .output(output_path, c='copy')
#             .overwrite_output()
#             .run(capture_stdout=True, capture_stderr=True)
#         )
#         print('Video trimmed successfully')
#         return True
#     except ffmpeg.Error as e:
#         print('FFmpeg Error:', e.stderr.decode())
#         return False
#     except Exception as e:
#         print('Unexpected error:', str(e))
#         return False

def trim_video_ffmpeg(input_path, output_path, end_time):
    print('this is different\n\n')
    try:
        if not os.path.exists(input_path):
            print(f"CRITICAL: File disappeared: {input_path}")
            print(f"Current working directory: {os.getcwd()}")
            return False

        try:
            with open(input_path, 'rb') as f:
                pass
        except IOError as io_err:
            print(f"Cannot open file: {io_err}")
            return False

        (
            ffmpeg
            .input(input_path, ss=0, t=end_time)
            .output(output_path, c='copy')
            .overwrite_output()
            .run()
        )
        print('Video trimmed successfully')
        return True
    except Exception as e:
        print('Something went wrong')
        print(traceback.format_exc())
        return False

# print(os.path.exists('../videos/inalnajfn8f98_0ee1262a-4bc8-4413-85d9-9ee3532cd4b8.mp4'))

def trim_video_optimized(orientation, input_file: str, output_file: str, end_time: float, start_time: int = 0):
    try:
        print('trying')
        resolutions = [(960, 540), (540, 960), (540, 540)]

        target_resolution = None
        if orientation == 'portrait': target_resolution = resolutions[0]
        elif orientation == 'landscape': target_resolution = resolutions[1]
        else: target_resolution = resolutions[2]
        
        video = VideoFileClip(
            input_file,
            audio=False,
            target_resolution= target_resolution,  
            resize_algorithm='fast_bilinear'  
        )
        
        trimmed_video = video.subclip(start_time, end_time)
        
        trimmed_video.write_videofile(
            output_file,
            codec='libx264',
            preset='ultrafast', 
            threads=4, 
            fps=30,
            bitrate=None, 
            audio=False,
            verbose=False
        )
        
        video.close()
        trimmed_video.close()
        
        return f"Video trimmed successfully and saved as {output_file}"
        
    except Exception as e:
        return f"Error occurred: {str(e)}"
    finally:
        try:
            video.close()
            trimmed_video.close()
        except:
            pass

def download_videos(urls, user_uuid, orientation):
    video_names = []
    for ind, url in enumerate(urls):
        print(ind)
        try:
            headers = {
                'Authorization': os.environ['PEXELS_API_KEY'],
                'User-Agent': 'Mozilla/5.0'  
            }

            print(url['video_url'])
            
            response = requests.get(url['video_url'], headers=headers)
            response.raise_for_status()
            
            output_filename = f"{user_uuid}_{uuid.uuid4()}.mp4"

            user_vid_dir = f'videos/{user_uuid}'
            if not os.path.exists(user_vid_dir):
                os.makedirs(user_vid_dir)

            with open(f'videos/{user_uuid}/{output_filename}', 'wb') as f:
                f.write(response.content)
            
            print(f"Video successfully downloaded as '{output_filename}'")
            end_time = 0
            if ind == 0:
                end_time = url['end'] - url['start']
            else:
                end_time = urls[ind]['end'] - urls[ind - 1]['end']

            trim_video_ffmpeg(f'videos/{user_uuid}/{output_filename}', f'videos/{user_uuid}/t_{output_filename}', end_time)
            # trim_video_optimized(orientation, f'videos/{user_uuid}/{output_filename}', f'videos/{user_uuid}/t_{output_filename}', end_time)
            
            video_names.append(f'videos/{user_uuid}/t_{output_filename}')

            os.remove(f'videos/{user_uuid}/{output_filename}')
            print(f'Trimmed video and deleted the previous one: {output_filename}\n')
            t_video = VideoFileClip(f'videos/{user_uuid}/t_{output_filename}')
            dur = t_video.duration
            t_video.close()
            print('DUR:', dur, '\n\n')

        except requests.exceptions.RequestException as e:
            print(f"Error downloading the video: {e}")
        except IOError as e:
            print(f"Error saving the file: {e}")

    return video_names