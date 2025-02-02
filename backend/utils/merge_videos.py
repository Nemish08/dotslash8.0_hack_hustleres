import ffmpeg, os
# from moviepy.video.io.VideoFileClip import VideoFileClip
from moviepy.editor import VideoFileClip, concatenate_videoclips
# from moviepy.video.compositing.concatenate import concatenate_videoclips

def merge_videos_in_directory(video_files, output_file, user_uuid):
    try:
        with open(f"{user_uuid}.txt", "w") as f:
            for video_path in video_files:
                f.write(f"file './{video_path}'\n")

        (
            ffmpeg
            .input(f"{user_uuid}.txt", format="concat", safe=0)
            .output(f"{output_file}.mp4", c="copy").run()
        )
    except Exception as e:
        print(e)

def merge_videos_optimized(video_files, output_file, user_uuid):
    temp_clips = []
    clips = []
    
    try:
        for video in video_files:
            print(video)
            clip = VideoFileClip(f'{video}', audio = False)
            clips.append(clip)

        final_concat = concatenate_videoclips(clips, method='compose')
        
        print("Writing final video...")
        final_concat.write_videofile(
            output_file,
            codec='libx264',
            preset='medium',
            threads=4,
            fps=30,
            bitrate='3000k',
            audio=False,
            verbose=False,
        )
        
    except Exception as e:
        print(f"An error occurred: {str(e)}")
        
    # finally:
    #     for clip in temp_clips:
    #         try:
    #             clip.close()
    #         except:
    #             pass
        
        # for video in video_files:
        #     os.remove(f'{video}')

    # try:
    #     if not video_files:
    #         print("No video files provided")
    #         return False
        
    #     if len(video_files) == 1:
    #         print("Only one video found. Copying the file.")
    #         input_stream = ffmpeg.input(video_files[0])
    #         input_stream.output(output_file, c='copy').run()
    #         return True
        
    #     input_streams = [ffmpeg.input(video) for video in video_files]
        
    #     (
    #         ffmpeg
    #         .concat(*input_streams)
    #         .output(output_file)
    #         .overwrite_output()
    #         .run()
    #     )
        
    #     print(f'Successfully merged {len(video_files)} videos to {output_file}')
    #     return True
    
    # except ffmpeg.Error as e:
    #     print(f'FFmpeg Error: {e.stderr.decode()}')
    #     return False
    # except Exception as e:
    #     print(f'Error merging videos: {e}')
    #     return False