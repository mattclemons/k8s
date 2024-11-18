from fastapi import FastAPI, Form, UploadFile
from fastapi.middleware.cors import CORSMiddleware
import yt_dlp
import ffmpeg
import whisper
import os
import logging

# Initialize FastAPI app
app = FastAPI()

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for testing; specify in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load the Whisper model (this can take time on startup)
logging.info("Loading Whisper model...")
model = whisper.load_model("base")  # Options: tiny, base, small, medium, large

@app.get("/")
async def root():
    return {"message": "Backend is running"}

@app.post("/transcribe/")
async def transcribe_video(url: str = Form(None), file: UploadFile = None):
    try:
        logging.info("Received request for transcription")

        # Step 1: Download or save the video
        if url:
            logging.info(f"Downloading video from URL: {url}")
            ydl_opts = {'outtmpl': 'video.mp4'}
            with yt_dlp.YoutubeDL(ydl_opts) as ydl:
                ydl.download([url])
            video_path = 'video.mp4'
        elif file:
            logging.info(f"Uploading file: {file.filename}")
            video_path = file.filename
            with open(video_path, "wb") as f:
                f.write(await file.read())
        else:
            return {"error": "Provide a URL or upload a file."}

        # Step 2: Extract audio from the video
        audio_path = "audio.wav"
        logging.info("Extracting audio from video")
        ffmpeg.input(video_path).output(audio_path).run()

        # Step 3: Transcribe audio using Whisper
        logging.info("Transcribing audio using Whisper")
        result = model.transcribe(audio_path)

        # Step 4: Clean up files
        os.remove(video_path)
        os.remove(audio_path)

        # Step 5: Return the transcription
        return {"transcription": result["text"]}

    except Exception as e:
        logging.error(f"Error during transcription: {e}")
        return {"error": str(e)}
