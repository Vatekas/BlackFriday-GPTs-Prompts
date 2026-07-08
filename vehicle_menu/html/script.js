window.addEventListener('message', function(event) {
    let data = event.data;

    if (data.type === "openMenu") {
        document.getElementById('app').style.display = 'flex';
    } else if (data.type === "closeMenu") {
        document.getElementById('app').style.display = 'none';
    } else if (data.type === "updateData") {
        document.getElementById('street-name').innerText = data.street || "Unknown Road";
        document.getElementById('engine-temp').innerText = Math.round(data.temperature) || 0;
        document.getElementById('fuel-fill').style.height = (data.fuel || 0) + '%';

        let now = new Date();
        document.getElementById('time-hour').innerText = String(now.getHours()).padStart(2, '0');
        document.getElementById('time-minute').innerText = String(now.getMinutes()).padStart(2, '0');

        // Update engine button state
        const engineBtn = document.getElementById('engine-btn');
        if (data.engineRunning) {
            engineBtn.style.color = '#b3ff00';
            engineBtn.querySelector('i').style.color = '#b3ff00';
        } else {
            engineBtn.style.color = '#fff';
            engineBtn.querySelector('i').style.color = '#fff';
        }
    }
});

document.onkeyup = function(data) {
    if (data.key == 'Escape') {
        closeMenu();
    }
};

function closeMenu() {
    fetch(`https://${GetParentResourceName()}/closeMenu`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    });
    document.getElementById('app').style.display = 'none';
}

function toggleEngine() {
    fetch(`https://${GetParentResourceName()}/toggleEngine`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    });
}

function changeSeat() {
    fetch(`https://${GetParentResourceName()}/changeSeat`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    });
}

function toggleLock() {
    fetch(`https://${GetParentResourceName()}/toggleLock`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    });
}

function toggleDoor(doorIndex) {
    fetch(`https://${GetParentResourceName()}/toggleDoor`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({ door: doorIndex })
    });

    // Simple visual toggle for the icon in NUI
    const doors = document.querySelectorAll('.lock-icon');
    if(doors[doorIndex]) {
        doors[doorIndex].classList.toggle('open');
        const icon = doors[doorIndex].querySelector('i');
        if(doors[doorIndex].classList.contains('open')) {
            icon.classList.remove('fa-lock');
            icon.classList.add('fa-lock-open');
        } else {
            icon.classList.remove('fa-lock-open');
            icon.classList.add('fa-lock');
        }
    }
}

function toggleInteriorLight() {
    fetch(`https://${GetParentResourceName()}/toggleInteriorLight`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    });
}

function toggleLights() {
    fetch(`https://${GetParentResourceName()}/toggleLights`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    });
}

function toggleHazards() {
    const isChecked = document.getElementById('hazard-toggle').checked;
    fetch(`https://${GetParentResourceName()}/toggleHazards`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({ state: isChecked })
    });
}