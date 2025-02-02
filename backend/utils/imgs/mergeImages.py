import os, ffmpeg

def create_video_from_images(image_duration_list, output_file):
    with open('input.txt', 'w') as f:
        for image_path, duration in image_duration_list:
            f.write(f"file '{image_path}'\n")
            f.write(f"duration {duration}\n")

    try:
        (
            ffmpeg
            .input('./input.txt', format='concat', safe=0)
            .output(output_file, c='libx264', r=30, pix_fmt='yuv420p')
            .run(overwrite_output=True)
        )
        print(f"Video successfully created as {output_file}")
    except ffmpeg.Error as e:
        print(f"An error occurred: {e.stderr.decode()}")

    os.remove('input.txt')

def create_video_from_images_web(image_duration_list, output_file):
    input_txt = 'input.txt'
    
    with open(input_txt, 'w') as f:
        for image_path, duration in image_duration_list:
            f.write(f"file '{image_path}'\n")
            f.write(f"duration {duration}\n")

    try:
        (
            ffmpeg
            .input('./input.txt', format='concat', safe=0)
            .output(output_file, c='libx264', r=30, pix_fmt='yuv420p', vf='scale=trunc(iw/2)*2:trunc(ih/2)*2')
            .run(overwrite_output=True)
        )
        print(f"✅ Video successfully created: {output_file}")
    
    except ffmpeg.Error as e:
        print(f"❌ FFmpeg Error: {e.stderr.decode() if e.stderr else 'Unknown error'}")

    # finally:
    #     if os.path.exists(input_txt):
    #         os.remove(input_txt)

# create_video_from_images_web([('../../images/mOXWUrIShsghrgx2xIJ5I6nIFcA3/0.jpg', 5.7), ('../../images/mOXWUrIShsghrgx2xIJ5I6nIFcA3/1.jpg', 2.0), ('../../images/mOXWUrIShsghrgx2xIJ5I6nIFcA3/2.jpg', 2.0), ('../../images/mOXWUrIShsghrgx2xIJ5I6nIFcA3/3.jpg', 2.0)], 'output.mp4')


# add_zoom_effect('../../images/187nksnuuhw7/2.png', 'OUTOUTOUT.mp4', zoom_duration=3, zoom_factor=1.5)
# create_zoom_video_2('../../images/187nksnuuhw7/2.png', 'OUTOUTOUT.mp4', zoom_duration=3, zoom_factor=1.5)

# def create_zoom_video(image_path, duration, zoom_effect=None, output_path="output.mp4"):
#     """
#     Create a video from an image with optional zoom-in or zoom-out effect.

#     Args:
#         image_path (str): Path to the input image.
#         duration (float): Duration of the output video in seconds.
#         zoom_effect (str): 'in' for zoom-in, 'out' for zoom-out, or None for no zoom effect.
#         output_path (str): Path to save the output video.

#     Returns:
#         None
#     """
#     try:
#         # Set the frames per second
#         fps = 30

#         # Calculate the total number of frames
#         total_frames = int(duration * fps)

#         # Define the initial zoom factor and the zoom increment per frame
#         if zoom_effect == 'in':
#             zoom_expr = "zoom+0.001"
#         elif zoom_effect == 'out':
#             zoom_expr = "zoom-0.001"
#         else:
#             zoom_expr = "1"

#         # Build the ffmpeg command
#         input_stream = ffmpeg.input(image_path, loop=1, framerate=fps)
#         video_stream = input_stream.filter(
#             'zoompan',
#             z=zoom_expr,
#             x='iw/2-(iw/zoom/2)',
#             y='ih/2-(ih/zoom/2)',
#             d=1,
#             s='1920x1080',
#             fps=fps
#         )

#         # Output the video
#         ffmpeg.output(video_stream, output_path, vcodec='libx264', pix_fmt='yuv420p', t=duration).run()
#         print(f"Video saved to {output_path}")

#     except ffmpeg.Error as e:
#         print("An error occurred while processing the video:", e)



# create_zoom_video("../../images/187nksnuuhw7/2.png", 3, 'in', 'output.mp4')
# create_slideshow(image_paths, durations, effects, output_path)

# create_video_from_images(image_duration_list, 'output_video.mp4')
# create_video_with_zoom_effects(image_duration_list, '../output_video.mp4')