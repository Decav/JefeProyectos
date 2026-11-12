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

def build_segments():
    # 1. Flow Shot 1 (3.0s, 1920x1080, 30fps)
    run_cmd([
        FFMPEG, "-y", "-i", f"{DIR}/Flow_Shot01_Jotunn_Blizzard.mp4",
        "-t", "3.0",
        "-vf", "scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080,fps=30",
        "-c:v", "libx264", "-pix_fmt", "yuv420p", f"{DIR}/seg_01_flow_jotunn.mp4"
    ])

    # 2. Flow Shot 2 (3.0s, 1920x1080, 30fps)
    run_cmd([
        FFMPEG, "-y", "-i", f"{DIR}/Flow_Shot02_Aerial_Village.mp4",
        "-t", "3.0",
        "-vf", "scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080,fps=30",
        "-c:v", "libx264", "-pix_fmt", "yuv420p", f"{DIR}/seg_02_flow_village.mp4"
    ])

    # 3. Gameplay River Bridge (4.0s, slow push-in)
    run_cmd([
        FFMPEG, "-y", "-loop", "1", "-i", f"{DIR}/Flow_References/Shot02_Ref_B_Aerial_River_Bridge_1920x1080.png",
        "-t", "4.0",
        "-vf", "zoompan=z='min(zoom+0.0012,1.15)':d=120:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':s=1920x1080:fps=30",
        "-c:v", "libx264", "-pix_fmt", "yuv420p", f"{DIR}/seg_03_river_bridge.mp4"
    ])

    # 4. Gameplay Frost Lord (4.0s, dramatic push)
    run_cmd([
        FFMPEG, "-y", "-loop", "1", "-i", f"{DIR}/Flow_References/Shot01_Ref_C_FrostLord_Avenue_1920x1080.png",
        "-t", "4.0",
        "-vf", "zoompan=z='min(zoom+0.0018,1.2)':d=120:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':s=1920x1080:fps=30",
        "-c:v", "libx264", "-pix_fmt", "yuv420p", f"{DIR}/seg_04_frost_lord.mp4"
    ])

    # 5. Gameplay Jotunn Dais (4.0s, cinematic zoom)
    run_cmd([
        FFMPEG, "-y", "-loop", "1", "-i", f"{DIR}/Flow_References/Shot01_Ref_A_Jotunn_InGame_1920x1080.png",
        "-t", "4.0",
        "-vf", "zoompan=z='min(zoom+0.0015,1.18)':d=120:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':s=1920x1080:fps=30",
        "-c:v", "libx264", "-pix_fmt", "yuv420p", f"{DIR}/seg_05_jotunn_dais.mp4"
    ])

    # 6. Gameplay Cavern Art (4.0s, slow glide)
    run_cmd([
        FFMPEG, "-y", "-loop", "1", "-i", f"{DIR}/Flow_References/Shot01_Ref_D_Jotunn_CavernArt_1920x1080.png",
        "-t", "4.0",
        "-vf", "zoompan=z='min(zoom+0.0012,1.15)':d=120:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':s=1920x1080:fps=30",
        "-c:v", "libx264", "-pix_fmt", "yuv420p", f"{DIR}/seg_06_cavern.mp4"
    ])

    # 7. Gameplay Deep Blizzard (4.0s, punch-in)
    run_cmd([
        FFMPEG, "-y", "-loop", "1", "-i", f"{DIR}/Flow_References/Shot01_Ref_B_Jotunn_Blizzard_1920x1080.png",
        "-t", "4.0",
        "-vf", "zoompan=z='min(zoom+0.0022,1.25)':d=120:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':s=1920x1080:fps=30",
        "-c:v", "libx264", "-pix_fmt", "yuv420p", f"{DIR}/seg_07_blizzard.mp4"
    ])

    # 8. EndCard CTA 16x9 (4.0s)
    run_cmd([
        FFMPEG, "-y", "-loop", "1", "-i", f"{DIR}/EndCard_CTA/Shot09_EndCard_CTA_16x9_1920x1080.png",
        "-t", "4.0",
        "-vf", "scale=1920:1080,fps=30",
        "-c:v", "libx264", "-pix_fmt", "yuv420p", f"{DIR}/seg_08_endcard_16x9.mp4"
    ])

if __name__ == "__main__":
    build_segments()
