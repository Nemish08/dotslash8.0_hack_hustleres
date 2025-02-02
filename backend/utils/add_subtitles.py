import ffmpeg, os

def format_time(seconds):
    hours, remainder = divmod(seconds, 3600)
    minutes, seconds = divmod(remainder, 60)
    milliseconds = int((seconds - int(seconds)) * 1000)
    return f"{int(hours):02}:{int(minutes):02}:{int(seconds):02},{milliseconds:03}"

def add_subtitles_ffmpeg(input_video: str, subtitles, output_video: str, uuid):
    with open(f'{uuid}_subtitles.srt', 'w', encoding='utf-8') as f:
        for ind, subtitle in enumerate(subtitles, start=1):
            start_time = format_time(subtitle['start'])
            end_time = format_time(subtitle['end'])
            text = subtitle['text']

            f.write(f"{ind}\n")
            f.write(f"{start_time} --> {end_time}\n")
            f.write(f"{text}\n\n")

    ffmpeg.input(input_video).output(output_video, vf=f'subtitles={uuid}_subtitles.srt').run()
    os.remove(f'{uuid}_subtitles.srt')

def format_time_ass(seconds):
    """Convert time to ASS subtitle format (H:MM:SS.ss)."""
    hours, remainder = divmod(seconds, 3600)
    minutes, seconds = divmod(remainder, 60)
    return f"{int(hours):01}:{int(minutes):02}:{int(seconds):02}.{int((seconds - int(seconds)) * 100)}"

def add_subtitles_ffmpeg_as(input_video: str, subtitles, output_video: str, uuid, style):
    subtitle_file = f"{uuid}_subtitles.ass"

    style_text = ''
    if style == "wbn":
        style_text = 'Style: wbn,Tahoma,11,&H00FFFFFF,&H70000000,&HFF000000,0,0,0,0,100,100,0,0,3,2,0,2,10,10,20,1'
    elif style == "wtn":
        style_text = 'Style: wtn,Tahoma,11,&H00FFFFFF,&HFF000000,&HFF000000,0,0,0,0,100,100,0,0,3,2,0,2,10,10,20,1'
    elif style == 'ybn':
        style_text = 'Style: ybn,Tahoma,11,&H0000FFFF,&H70000000,&HFF000000,0,0,0,0,100,100,0,0,3,2,0,2,10,10,20,1'
    elif style == 'ytn':
        style_text = 'Style: ytn,Tahoma,11,&H0000FFFF,&HFF000000,&HFF000000,0,0,0,0,100,100,0,0,3,0,0,2,10,10,20,1'
    elif style == 'wbi':
        style_text = 'Style: wbi,Tahoma,11,&H00FFFFFF,&H70000000,&HFF000000,0,1,0,0,100,100,0,0,3,2,0,2,10,10,20,1'
    elif style == 'wti':
        style_text = 'Style: wti,Tahoma,11,&H00FFFFFF,&HFF000000,&HFF000000,0,1,0,0,100,100,0,0,3,2,0,2,10,10,20,1'
    elif style == 'ybi':
        style_text = 'Style: ybi,Tahoma,11,&H0000FFFF,&H70000000,&HFF000000,0,1,0,0,100,100,0,0,3,2,0,2,10,10,20,1'
    elif style == 'yti':
        style_text = 'Style: yti,Tahoma,11,&H0000FFFF,&HFF000000,&HFF000000,0,1,0,0,100,100,0,0,3,0,0,2,10,10,20,1'

    with open(subtitle_file, 'w', encoding='utf-8') as f:
        f.write("[Script Info]\n")
        f.write("Title: Styled Subtitles\n")
        f.write("ScriptType: v4.00+\n\n")

        f.write("[V4+ Styles]\n")
        f.write("Format: Name, Fontname, Fontsize, PrimaryColour, OutlineColour, BackColour, "
                "Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, "
                "Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding\n")
        f.write(f"{style_text}\n\n")

        f.write("[Events]\n")
        f.write("Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text\n")

        for subtitle in subtitles:
            start_time = format_time_ass(subtitle['start'])
            end_time = format_time_ass(subtitle['end'])
            text = subtitle['text']

            f.write(f"Dialogue: 0,{start_time},{end_time},{style},,0,0,0,,{text}\n")
        
    ffmpeg.input(input_video).output(output_video, vf=f"subtitles={subtitle_file}").run(overwrite_output=True)
    os.remove(subtitle_file)



# testing
def add_subtitles_ffmpeg(input_video: str, subtitle_file: str, output_video: str):
    # Apply subtitles with styling
    # ffmpeg.input(input_video).output(
    #     output_video,
    #     vf=f"subtitles={subtitle_file}:force_style='FontName={font_name},FontSize={font_size},PrimaryColour=&H00{font_color},OutlineColour=&H00{border_color},BackColour=&H800000{background_color},Bold=1,Outline=1,Shadow=1'"
    # ).run(overwrite_output=True)

    ffmpeg.input(input_video).output(output_video, vf=f"subtitles={subtitle_file}").run(overwrite_output=True)


    print(f"Subtitled video saved as {output_video}")

# add_subtitles_ffmpeg("../videos/mOXWUrIShsghrgx2xIJ5I6nIFcA3/t_mOXWUrIShsghrgx2xIJ5I6nIFcA3_66eb0151-3c08-44ae-9d1d-38a2fe07720b.mp4", "../sub.ass", "OUTPUT.mp4")