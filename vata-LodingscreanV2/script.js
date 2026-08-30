// --- Server Info Toggle ---
const flagBtn = document.getElementById('flagBtn');
const serverDesc = document.getElementById('serverDescription');

flagBtn.addEventListener('click', () => {
    serverDesc.classList.toggle('hidden');
});

// --- Did You Know? (Facts Logic) ---
const facts = [
    "Šis serveris startavo neseniai!",
    "Norėdami kalbėti, naudokite 'N' mygtuką.",
    "Būkite draugiški ir laikykitės serverio taisyklių.",
    "LunaX serveryje visada rasite veiklos!",
    "Prisijunkite prie mūsų Discord, kad nepraleistumėte naujienų!"
];

const factText = document.getElementById('factText');
let currentFactIndex = 0;

setInterval(() => {
    factText.style.opacity = 0; // Fade out
    setTimeout(() => {
        currentFactIndex = (currentFactIndex + 1) % facts.length;
        factText.textContent = facts[currentFactIndex];
        factText.style.opacity = 1; // Fade in
    }, 500); // Wait for fade out to complete before changing text
}, 5000); // Change fact every 5 seconds

// --- Music Player Logic ---
const bgMusic = document.getElementById('bgMusic');
const playPauseBtn = document.getElementById('playPauseBtn');
const prevBtn = document.getElementById('prevBtn');
const nextBtn = document.getElementById('nextBtn');
const volumeSlider = document.getElementById('volumeSlider');
const playIcon = playPauseBtn.querySelector('i');

let isPlaying = false;

// Set initial volume
bgMusic.volume = volumeSlider.value / 100;

playPauseBtn.addEventListener('click', () => {
    if (isPlaying) {
        bgMusic.pause();
        playIcon.classList.remove('fa-pause');
        playIcon.classList.add('fa-play');
    } else {
        bgMusic.play().catch(e => console.log("Audio play failed:", e));
        playIcon.classList.remove('fa-play');
        playIcon.classList.add('fa-pause');
    }
    isPlaying = !isPlaying;
});

volumeSlider.addEventListener('input', (e) => {
    bgMusic.volume = e.target.value / 100;
});

// Placeholder for next/prev if multiple songs are added later
prevBtn.addEventListener('click', () => {
    bgMusic.currentTime = 0; // Reset current song
});

nextBtn.addEventListener('click', () => {
    bgMusic.currentTime = 0; // Reset current song
});

// --- FiveM Loading Progress Logic ---
const loadingBar = document.getElementById('loadingBar');
const loadingPercentage = document.getElementById('loadingPercentage');

let count = 0;
let thisCount = 0;

const handlers = {
    startInitFunctionOrder(data) {
        count = data.count;
    },
    initFunctionInvoking(data) {
        document.querySelector('.loading-bar').style.left = '0%';
        document.querySelector('.loading-bar').style.width = ((data.idx / count) * 100) + '%';
        loadingPercentage.innerText = Math.round((data.idx / count) * 100) + '%';
    },
    startDataFileEntries(data) {
        count = data.count;
    },
    performMapLoadFunction(data) {
        ++thisCount;
        document.querySelector('.loading-bar').style.left = '0%';
        document.querySelector('.loading-bar').style.width = ((thisCount / count) * 100) + '%';
        loadingPercentage.innerText = Math.round((thisCount / count) * 100) + '%';
    },
    onLogLine(data) {
        // Optional: display log line somewhere
    }
};

window.addEventListener('message', function (e) {
    (handlers[e.data.eventName] || function () { })(e.data);
});

// Simulated progress for preview/testing outside of FiveM
let simProgress = 0;
if (!window.invokeNative) {
    setInterval(() => {
        if (simProgress < 100) {
            simProgress += Math.floor(Math.random() * 5) + 1;
            if (simProgress > 100) simProgress = 100;
            loadingBar.style.width = simProgress + '%';
            loadingPercentage.innerText = simProgress + '%';
        }
    }, 1000);
}
