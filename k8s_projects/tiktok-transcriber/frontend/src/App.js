import React, { useState } from "react";
import axios from "axios";

function App() {
    const [url, setUrl] = useState("");
    const [file, setFile] = useState(null);
    const [transcription, setTranscription] = useState("");

    const handleSubmit = async (e) => {
        e.preventDefault();
        const formData = new FormData();
        if (url) formData.append("url", url);
        if (file) formData.append("file", file);

        const response = await axios.post("http://localhost:8000/transcribe/", formData);
        setTranscription(response.data.transcription);
    };

    return (
        <div>
            <h1>TikTok Video Transcriber</h1>
            <form onSubmit={handleSubmit}>
                <input
                    type="text"
                    placeholder="TikTok Video URL"
                    value={url}
                    onChange={(e) => setUrl(e.target.value)}
                />
                <input
                    type="file"
                    onChange={(e) => setFile(e.target.files[0])}
                />
                <button type="submit">Transcribe</button>
            </form>
            <h2>Transcription:</h2>
            <p>{transcription}</p>
        </div>
    );
}

export default App;
