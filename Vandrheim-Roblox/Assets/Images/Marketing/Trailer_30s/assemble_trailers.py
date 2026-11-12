import os
import subprocess

DIR = "/Users/diego/developer/JefeProyectos/Vandrheim-Roblox/Assets/Images/Marketing/Trailer_30s"
FFMPEG = "/opt/homebrew/bin/ffmpeg"
MUSIC = "/Users/diego/developer/JefeProyectos/Vandrheim-Roblox/Assets/Sounds/music/Vandrheim-Frost-JotunnBossFight.mp3"

def run_cmd(cmd):
    print("Running:", " ".join(cmd))
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        print("STDERR:", res.stderr)
        raise RuntimeError(f"Command failed: {res.returncode}")
    print("SUCCESS")

def assemble():
    # -------------------------------------------------------------
    # 1. Master 16:9 (30s)
    # -------------------------------------------------------------
    concat_list = f"{DIR}/concat_master.txt"
    with open(concat_list, "w") as f:
        f.write(f"file '{DIR}/seg_01_flow_jotunn.mp4'\n")
        f.write(f"file '{DIR}/seg_02_flow_village.mp4'\n")
        f.write(f"file '{DIR}/seg_03_river_bridge.mp4'\n")
        f.write(f"file '{DIR}/seg_04_frost_lord.mp4'\n")
        f.write(f"file '{DIR}/seg_05_jotunn_dais.mp4'\n")
        f.write(f"file '{DIR}/seg_06_cavern.mp4'\n")
        f.write(f"file '{DIR}/seg_07_blizzard.mp4'\n")
        f.write(f"file '{DIR}/seg_08_endcard_16x9.mp4'\n")

    # Concatenate video and mix with music (-14 LUFS, 0.5s fade out at end)
    master_out = f"{DIR}/Vandrheim_Trailer_Master_30s_16x9.mp4"
    run_cmd([
        FFMPEG, "-y",
        "-f", "concat", "-safe", "0", "-i", concat_list,
        "-ss", "00:00:05", "-t", "30.0", "-i", MUSIC,
        "-i", f"{DIR}/Subtitles/Vandrheim_Trailer_30s_ES.srt",
        "-filter_complex", "[1:a]afade=t=out:st=29.5:d=0.5,loudnorm=I=-14:TP=-1.0:LRA=11[aout]",
        "-map", "0:v",
        "-map", "[aout]",
        "-map", "2:s?",
        "-c:v", "libx264", "-preset", "medium", "-crf", "18", "-pix_fmt", "yuv420p",
        "-c:a", "aac", "-b:a", "192k",
        "-c:s", "mov_text",
        "-metadata:s:s:0", "language=spa",
        master_out
    ])

    # -------------------------------------------------------------
    # 2. Vertical 9:16 (15s)
    # Segments:
    # - 0:00 - 0:03 (3s): Flow Jotunn (cropped/scaled to 1080x1920)
    # - 0:03 - 0:06 (3s): Flow Village (cropped/scaled to 1080x1920)
    # - 0:06 - 0:09 (3s): Frost Lord Avenue (cropped/scaled to 1080x1920)
    # - 0:09 - 0:12 (3s): Jotunn Dais (cropped/scaled to 1080x1920)
    # - 0:12 - 0:15 (3s): EndCard CTA 9x16
    # -------------------------------------------------------------
    # Render vertical segments
    v_seg1 = f"{DIR}/vseg_01_jotunn.mp4"
    run_cmd([
        FFMPEG, "-y", "-i", f"{DIR}/Flow_Shot01_Jotunn_Blizzard.mp4",
        "-t", "3.0",
        "-vf", "scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,fps=30",
        "-c:v", "libx264", "-pix_fmt", "yuv420p", v_seg1
    ])

    v_seg2 = f"{DIR}/vseg_02_village.mp4"
    run_cmd([
        FFMPEG, "-y", "-i", f"{DIR}/Flow_Shot02_Aerial_Village.mp4",
        "-t", "3.0",
        "-vf", "scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,fps=30",
        "-c:v", "libx264", "-pix_fmt", "yuv420p", v_seg2
    ])

    v_seg3 = f"{DIR}/vseg_03_frostlord.mp4"
    run_cmd([
        FFMPEG, "-y", "-loop", "1", "-i", f"{DIR}/Flow_References/Shot01_Ref_C_FrostLord_Avenue_1920x1080.png",
        "-t", "3.0",
        "-vf", "zoompan=z='min(zoom+0.002,1.2)':d=90:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':s=1080x1920:fps=30",
        "-c:v", "libx264", "-pix_fmt", "yuv420p", v_seg3
    ])

    v_seg4 = f"{DIR}/vseg_04_jotunndais.mp4"
    run_cmd([
        FFMPEG, "-y", "-loop", "1", "-i", f"{DIR}/Flow_References/Shot01_Ref_A_Jotunn_InGame_1920x1080.png",
        "-t", "3.0",
        "-vf", "zoompan=z='min(zoom+0.002,1.2)':d=90:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':s=1080x1920:fps=30",
        "-c:v", "libx264", "-pix_fmt", "yuv420p", v_seg4
    ])

    v_seg5 = f"{DIR}/vseg_05_endcard.mp4"
    run_cmd([
        FFMPEG, "-y", "-loop", "1", "-i", f"{DIR}/EndCard_CTA/Shot09_EndCard_CTA_9x16_1080x1920.png",
        "-t", "3.0",
        "-vf", "scale=1080:1920,fps=30",
        "-c:v", "libx264", "-pix_fmt", "yuv420p", v_seg5
    ])

    concat_vert = f"{DIR}/concat_vertical.txt"
    with open(concat_vert, "w") as f:
        f.write(f"file '{v_seg1}'\n")
        f.write(f"file '{v_seg2}'\n")
        f.write(f"file '{v_seg3}'\n")
        f.write(f"file '{v_seg4}'\n")
        f.write(f"file '{v_seg5}'\n")

    vert_out = f"{DIR}/Vandrheim_Trailer_Vertical_15s_9x16.mp4"
    run_cmd([
        FFMPEG, "-y",
        "-f", "concat", "-safe", "0", "-i", concat_vert,
        "-ss", "00:00:15", "-t", "15.0", "-i", MUSIC,
        "-i", f"{DIR}/Subtitles/Vandrheim_Vertical_15s_ES.srt",
        "-filter_complex", "[1:a]afade=t=out:st=14.5:d=0.5,loudnorm=I=-14:TP=-1.0:LRA=11[aout]",
        "-map", "0:v",
        "-map", "[aout]",
        "-map", "2:s?",
        "-c:v", "libx264", "-preset", "medium", "-crf", "18", "-pix_fmt", "yuv420p",
        "-c:a", "aac", "-b:a", "192k",
        "-c:s", "mov_text",
        "-metadata:s:s:0", "language=spa",
        vert_out
    ])

    # -------------------------------------------------------------
    # 3. Hook 9:16 (6s)
    # Segments:
    # - 0:00 - 0:03 (3s): Flow Jotunn
    # - 0:03 - 0:05 (2s): Frost Lord Avenue climax
    # - 0:05 - 0:06 (1s): EndCard CTA 9x16
    # -------------------------------------------------------------
    h_seg1 = v_seg1  # 3.0s

    h_seg2 = f"{DIR}/hseg_02_frostlord.mp4"
    run_cmd([
        FFMPEG, "-y", "-loop", "1", "-i", f"{DIR}/Flow_References/Shot01_Ref_C_FrostLord_Avenue_1920x1080.png",
        "-t", "2.0",
        "-vf", "zoompan=z='min(zoom+0.003,1.3)':d=60:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':s=1080x1920:fps=30",
        "-c:v", "libx264", "-pix_fmt", "yuv420p", h_seg2
    ])

    h_seg3 = f"{DIR}/hseg_03_endcard.mp4"
    run_cmd([
        FFMPEG, "-y", "-loop", "1", "-i", f"{DIR}/EndCard_CTA/Shot09_EndCard_CTA_9x16_1080x1920.png",
        "-t", "1.0",
        "-vf", "scale=1080:1920,fps=30",
        "-c:v", "libx264", "-pix_fmt", "yuv420p", h_seg3
    ])

    concat_hook = f"{DIR}/concat_hook.txt"
    with open(concat_hook, "w") as f:
        f.write(f"file '{h_seg1}'\n")
        f.write(f"file '{h_seg2}'\n")
        f.write(f"file '{h_seg3}'\n")

    hook_out = f"{DIR}/Vandrheim_Trailer_Hook_6s_9x16.mp4"
    run_cmd([
        FFMPEG, "-y",
        "-f", "concat", "-safe", "0", "-i", concat_hook,
        "-ss", "00:00:20", "-t", "6.0", "-i", MUSIC,
        "-i", f"{DIR}/Subtitles/Vandrheim_Hook_6s_ES.srt",
        "-filter_complex", "[1:a]afade=t=out:st=5.7:d=0.3,loudnorm=I=-14:TP=-1.0:LRA=11[aout]",
        "-map", "0:v",
        "-map", "[aout]",
        "-map", "2:s?",
        "-c:v", "libx264", "-preset", "medium", "-crf", "18", "-pix_fmt", "yuv420p",
        "-c:a", "aac", "-b:a", "192k",
        "-c:s", "mov_text",
        "-metadata:s:s:0", "language=spa",
        hook_out
    ])

    print("ALL THREE TRAILERS ASSEMBLED SUCCESSFULLY!")

if __name__ == "__main__":
    assemble()
