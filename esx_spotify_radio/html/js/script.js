let isPlaying = false;
let currentSongUrl = "";
let currentSongTitle = "Nėra grojamos dainos";
let currentSongThumbnail = "https://via.placeholder.com/60";
let savedSongsList = [];

// Listen for NUI Messages from client.lua
window.addEventListener('message', function(event) {
    let data = event.data;

    if (data.action === "openUI") {
        document.getElementById('app').style.display = 'flex';
        savedSongsList = data.savedSongs || [];
        renderSavedSongs();
    } else if (data.action === "closeUI") {
        document.getElementById('app').style.display = 'none';
    }
});

// Close UI
document.getElementById('close-ui-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify({})
    });
});

// Close on Escape key
document.addEventListener('keyup', function(e) {
    if (e.key === 'Escape') {
        fetch(`https://${GetParentResourceName()}/close`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify({})
        });
    }
});

// Fetch YouTube Info
async function getYouTubeInfo(url) {
    try {
        // Simple way to get title and thumbnail via noembed
        const response = await fetch(`https://noembed.com/embed?url=${url}`);
        const data = await response.json();
        return {
            title: data.title || "Nežinoma daina",
            thumbnail: data.thumbnail_url || "https://via.placeholder.com/60",
            url: url
        };
    } catch (error) {
        console.error("Error fetching youtube info", error);
        return {
            title: "Nežinoma daina",
            thumbnail: "https://via.placeholder.com/60",
            url: url
        };
    }
}

function updateNowPlaying(title, thumbnail) {
    document.getElementById('now-playing-title').innerText = title;
    document.getElementById('now-playing-img').src = thumbnail;
    document.getElementById('now-playing-artist').innerText = "YouTube Audio";
}

function renderSavedSongs() {
    const container = document.getElementById('saved-songs-list');
    container.innerHTML = '';

    savedSongsList.forEach(song => {
        const div = document.createElement('div');
        div.className = 'playlist-item';
        div.innerHTML = `
            <img src="${song.thumbnail}" alt="thumb">
            <div class="playlist-item-info">
                <h4>${song.title}</h4>
                <p>Išsaugota</p>
            </div>
        `;
        div.onclick = () => {
            playNewSong(song.url, song.title, song.thumbnail);
        };
        container.appendChild(div);
    });
}

async function playNewSong(url, predefinedTitle, predefinedThumb) {
    let title = predefinedTitle;
    let thumb = predefinedThumb;

    if (!title || !thumb) {
        const info = await getYouTubeInfo(url);
        title = info.title;
        thumb = info.thumbnail;
    }

    currentSongUrl = url;
    currentSongTitle = title;
    currentSongThumbnail = thumb;

    updateNowPlaying(title, thumb);
    isPlaying = true;
    document.getElementById('play-icon').classList.remove('fa-play');
    document.getElementById('play-icon').classList.add('fa-pause');

    fetch(`https://${GetParentResourceName()}/playSong`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify({ url: url })
    });
}

// Search / Play button
document.getElementById('search-btn').addEventListener('click', () => {
    const url = document.getElementById('youtube-url-input').value;
    if (url && url.includes("youtu")) {
        playNewSong(url);
    }
});

// Play / Pause button
document.getElementById('play-pause-btn').addEventListener('click', () => {
    if (!currentSongUrl) return;

    isPlaying = !isPlaying;
    const icon = document.getElementById('play-icon');

    if (isPlaying) {
        icon.classList.remove('fa-play');
        icon.classList.add('fa-pause');
        fetch(`https://${GetParentResourceName()}/resumeSong`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify({})
        });
    } else {
        icon.classList.remove('fa-pause');
        icon.classList.add('fa-play');
        fetch(`https://${GetParentResourceName()}/pauseSong`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify({})
        });
    }
});

// Stop button
document.getElementById('stop-btn').addEventListener('click', () => {
    isPlaying = false;
    currentSongUrl = "";
    document.getElementById('play-icon').classList.remove('fa-pause');
    document.getElementById('play-icon').classList.add('fa-play');
    updateNowPlaying("Nėra grojamos dainos", "https://via.placeholder.com/60");

    fetch(`https://${GetParentResourceName()}/stopSong`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify({})
    });
});

// Volume
document.getElementById('volume-slider').addEventListener('input', (e) => {
    const vol = e.target.value / 100;
    fetch(`https://${GetParentResourceName()}/setVolume`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify({ volume: vol })
    });
});

// Save Song
document.getElementById('save-current-song').addEventListener('click', () => {
    if (currentSongUrl) {
        fetch(`https://${GetParentResourceName()}/saveSong`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify({
                url: currentSongUrl,
                title: currentSongTitle,
                thumbnail: currentSongThumbnail
            })
        });

        // Optimistically add to list
        savedSongsList.push({
            url: currentSongUrl,
            title: currentSongTitle,
            thumbnail: currentSongThumbnail
        });
        renderSavedSongs();
    }
});

// Skip buttons (Prev/Next) - For now just stops or plays random from saved if available
document.getElementById('next-btn').addEventListener('click', () => {
    if (savedSongsList.length > 0) {
        const randomSong = savedSongsList[Math.floor(Math.random() * savedSongsList.length)];
        playNewSong(randomSong.url, randomSong.title, randomSong.thumbnail);
    }
});
