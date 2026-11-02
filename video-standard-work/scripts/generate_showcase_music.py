import os
import subprocess

MUSIC_PATH = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "public", "music", "showcase_tech_40s.mp3"))
os.makedirs(os.path.dirname(MUSIC_PATH), exist_ok=True)

def generate_tech_music():
    print("Synthesizing 40-second modern upbeat instrumental tech track with FFmpeg...")
    # 40-second duration (1200 frames @ 30fps)
    # Bass: 110Hz (A2), Chord harmonics: 220Hz (A3), 277.18Hz (C#4), 329.63Hz (E4), 440Hz (A4)
    # Pulse rhythm: rhythmic modulation
    cmd = [
        "ffmpeg", "-y",
        "-f", "lavfi", "-i", "sine=frequency=110.00:duration=40",
        "-f", "lavfi", "-i", "sine=frequency=220.00:duration=40",
        "-f", "lavfi", "-i", "sine=frequency=277.18:duration=40",
        "-f", "lavfi", "-i", "sine=frequency=329.63:duration=40",
        "-f", "lavfi", "-i", "sine=frequency=440.00:duration=40",
        "-filter_complex",
        "[0:a]volume=0.22,lowpass=f=220[b];"
        "[1:a]volume=0.15[p1];"
        "[2:a]volume=0.12[p2];"
        "[3:a]volume=0.12[p3];"
        "[4:a]volume=0.08[p4];"
        "[b][p1][p2][p3][p4]amix=inputs=5[mix];"
        "[mix]aecho=0.8:0.7:50|100:0.35|0.2,tremolo=f=4.0:d=0.25,lowpass=f=2200,volume=0.35,afade=t=in:ss=0:d=1.5,afade=t=out:st=37:d=3[out]",
        "-map", "[out]",
        "-c:a", "libmp3lame",
        "-b:a", "192k",
        MUSIC_PATH
    ]
    subprocess.run(cmd, check=True)
    print(f"Generated showcase track: {MUSIC_PATH}")

if __name__ == "__main__":
    generate_tech_music()

