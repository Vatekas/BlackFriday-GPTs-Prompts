// Klausomės NUI žinučių iš Lua kliento
window.addEventListener('message', function(event) {
    if (event.data.type === "ui") {
        if (event.data.status) {
            document.getElementById("phone-container").style.display = "flex";

            // Re-trigger the SVG animation by cloning the path element and replacing it
            const svgPath = document.querySelector('.hello-path');
            if (svgPath) {
                svgPath.classList.remove('animate-hello');
                // Trigger reflow to restart animation
                void svgPath.offsetWidth;
                svgPath.classList.add('animate-hello');
            }
        } else {
            document.getElementById("phone-container").style.display = "none";
        }
    }
});

// Uždaryti telefoną paspaudus Escape
document.onkeyup = function(data) {
    if (data.which == 27) { // Escape klavišas
        fetch(`https://${GetParentResourceName()}/close`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        });
    }
};

// Laikrodžio atnaujinimas
function updateClock() {
    const now = new Date();
    let hours = now.getHours();
    let minutes = now.getMinutes();

    hours = hours < 10 ? '0' + hours : hours;
    minutes = minutes < 10 ? '0' + minutes : minutes;

    document.getElementById('clock').textContent = `${hours}:${minutes}`;
}

// Paleisti laikrodį ir atnaujinti kas sekundę
setInterval(updateClock, 1000);
updateClock(); // Iškviečiame iš karto
