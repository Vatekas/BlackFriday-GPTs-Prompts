document.addEventListener('DOMContentLoaded', () => {
    // --- Slide-out Panel Logic ---
    const toggleAboutBtn = document.getElementById('toggle-about');
    const aboutPanel = document.getElementById('about-panel');

    toggleAboutBtn.addEventListener('click', () => {
        aboutPanel.classList.toggle('open');
    });

    // --- Rotating Facts Logic ---
    const facts = document.querySelectorAll('.fact-item');
    let currentFactIndex = 0;

    // Rotate every 5 seconds (5000 milliseconds)
    setInterval(() => {
        // Remove active class from current fact
        facts[currentFactIndex].classList.remove('active');

        // Calculate next index
        currentFactIndex = (currentFactIndex + 1) % facts.length;

        // Add active class to new fact
        facts[currentFactIndex].classList.add('active');
    }, 5000);

    // --- Audio Controls Logic ---
    // (Simulated UI logic since there's no actual music required yet based on instructions)
    const playPauseBtn = document.getElementById('audio-playpause');
    const prevBtn = document.getElementById('audio-prev');
    const nextBtn = document.getElementById('audio-next');
    const volumeSlider = document.getElementById('volume-slider');

    let isPlaying = false; // Initially paused/no music

    playPauseBtn.addEventListener('click', () => {
        isPlaying = !isPlaying;
        if (isPlaying) {
            playPauseBtn.classList.remove('fa-play');
            playPauseBtn.classList.add('fa-pause');
        } else {
            playPauseBtn.classList.remove('fa-pause');
            playPauseBtn.classList.add('fa-play');
        }
    });

    prevBtn.addEventListener('click', () => {
        // Simulate previous track
        console.log('Previous track clicked');
    });

    nextBtn.addEventListener('click', () => {
        // Simulate next track
        console.log('Next track clicked');
    });

    volumeSlider.addEventListener('input', (e) => {
        // Simulate volume change
        const volume = e.target.value;
        console.log(`Volume changed to ${volume}%`);
    });
});