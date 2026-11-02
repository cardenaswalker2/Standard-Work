import os
import subprocess

MUSIC_PATH = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "public", "music", "background_corporate.mp3"))
os.makedirs(os.path.dirname(MUSIC_PATH), exist_ok=True)

def generate_ambient_music():
    print("Synthesizing ambient corporate background track with FFmpeg...")
    cmd = [
        "ffmpeg", "-y",
        "-f", "lavfi", "-i", "sine=frequency=87.31:duration=150",
        "-f", "lavfi", "-i", "sine=frequency=174.61:duration=150",
        "-f", "lavfi", "-i", "sine=frequency=220.00:duration=150",
        "-f", "lavfi", "-i", "sine=frequency=261.63:duration=150",
        "-f", "lavfi", "-i", "sine=frequency=349.23:duration=150",
        "-filter_complex",
        "[0:a]volume=0.20,lowpass=f=200[b];"
        "[1:a]volume=0.12[p1];"
        "[2:a]volume=0.09[p2];"
        "[3:a]volume=0.09[p3];"
        "[4:a]volume=0.06[p4];"
        "[b][p1][p2][p3][p4]amix=inputs=5[mix];"
        "[mix]aecho=0.8:0.7:60|120:0.3|0.2,lowpass=f=1400,volume=0.18,afade=t=in:ss=0:d=3,afade=t=out:st=145:d=5[out]",
        "-map", "[out]",
        "-c:a", "libmp3lame",
        "-b:a", "192k",
        MUSIC_PATH
    ]
    subprocess.run(cmd, check=True)
    print(f"Generated corporate ambient track: {MUSIC_PATH}")

if __name__ == "__main__":
    generate_ambient_music()
