$(document).ready(function() {
    let currentApp = "";

    // Update time
    function updateTime() {
        const now = new Date();
        const hours = String(now.getHours()).padStart(2, '0');
        const minutes = String(now.getMinutes()).padStart(2, '0');
        $('.time').text(`${hours}:${minutes}`);
    }

    setInterval(updateTime, 1000);
    updateTime();

    // Listen for NUI Messages from client script
    window.addEventListener('message', function(event) {
        let data = event.data;
        if (data.type === "ui") {
            if (data.status) {
                $('#app').fadeIn(300);
            } else {
                $('#app').fadeOut(300);
                resetTV();
            }
        }
    });

    // Close Button Click
    $('#close-btn').click(function() {
        closeTV();
    });

    // Close on ESC key
    document.onkeyup = function(data) {
        if (data.which == 27) { // ESC
            closeTV();
        }
    };

    // App Clicks
    $('.app').click(function() {
        currentApp = $(this).data('app');

        if (currentApp === "youtube") {
            $('#home-screen').fadeOut(200, function() {
                $('#input-title').text("Enter YouTube URL or Video ID");
                $('#url-input').val("").focus();
                $('#input-screen').fadeIn(200);
            });
        } else if (currentApp === "spotify") {
            openApp("https://open.spotify.com/embed/track/3n3Ppam7vgaVa1iaRUc9Lp");
        }
    });

    // Cancel Input
    $('#cancel-btn').click(function() {
        $('#input-screen').fadeOut(200, function() {
            $('#home-screen').fadeIn(200);
        });
    });

    // Play Input
    $('#play-btn').click(function() {
        let input = $('#url-input').val().trim();
        if (input === "") return;

        let videoId = extractYouTubeID(input);

        if (videoId) {
            let url = `https://www.youtube.com/embed/${videoId}?autoplay=1`;
            $('#input-screen').fadeOut(200, function() {
                openApp(url);
            });
        } else {
            alert("Invalid YouTube URL or ID");
        }
    });

    // Handle Enter key on input
    $('#url-input').keypress(function(e) {
        if(e.which == 13) {
            $('#play-btn').click();
        }
    });

    // Back to Home Button
    $('#back-btn').click(function() {
        resetTV();
    });

    function openApp(url) {
        $('#home-screen').hide();
        $('#input-screen').hide();
        $('#browser-frame').attr('src', url);
        $('#iframe-container').fadeIn(200);
    }

    function resetTV() {
        $('#iframe-container').fadeOut(200, function() {
            $('#browser-frame').attr('src', '');
            $('#input-screen').hide();
            $('#home-screen').fadeIn(200);
        });
    }

    function closeTV() {
        $.post('https://vata-tv/close', JSON.stringify({}));
    }

    // Helper to extract YouTube ID
    function extractYouTubeID(url) {
        let regExp = /^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#&?]*).*/;
        let match = url.match(regExp);
        if (match && match[7].length == 11) {
            return match[7];
        } else if (url.length === 11) {
            return url; // Assume it's an ID if it's 11 chars
        }
        return false;
    }
});
