window.addEventListener('message', function(event) {
    let data = event.data;

    if (data.type === "openMenu") {
        document.getElementById('app').style.display = 'flex';

        // Update translations
        if (data.translations) {
            if (document.getElementById('lang-weather-title')) document.getElementById('lang-weather-title').innerText = data.translations.weather.toUpperCase();
            if (document.getElementById('lang-lock')) document.getElementById('lang-lock').innerText = data.translations.lock;
            if (document.getElementById('lang-seat')) document.getElementById('lang-seat').innerText = data.translations.seat;
            if (document.getElementById('lang-engine')) document.getElementById('lang-engine').innerText = data.translations.engine;
            if (document.getElementById('lang-interior')) document.getElementById('lang-interior').innerText = data.translations.interior_light.replace('\\n', '\n');
            if (document.getElementById('lang-lights')) document.getElementById('lang-lights').innerText = data.translations.lights;
            if (document.getElementById('lang-engine-temp-label')) document.getElementById('lang-engine-temp-label').innerText = data.translations.engine;
            if (document.getElementById('lang-emergency')) document.getElementById('lang-emergency').innerText = data.translations.emergency;
        }

    } else if (data.type === "closeMenu") {
        document.getElementById('app').style.display = 'none';
    } else if (data.type === "updateData") {
        document.getElementById('street-name').innerText = data.street || "Unknown Road";
        document.getElementById('engine-temp').innerText = Math.round(data.temperature) || 0;
        document.getElementById('fuel-fill').style.height = (data.fuel || 0) + '%';

        if (data.time) {
            document.getElementById('time-hour').innerText = String(data.time.hour).padStart(2, '0');
            document.getElementById('time-minute').innerText = String(data.time.minute).padStart(2, '0');
        }

        // Update engine button state
        const engineBtn = document.getElementById('engine-btn');
        if (data.engineRunning) {
            engineBtn.style.color = '#b3ff00';
            engineBtn.querySelector('svg').style.color = '#b3ff00';
        } else {
            engineBtn.style.color = '#fff';
            engineBtn.querySelector('svg').style.color = '#fff';
        }

        // Update main lock button state
        const lockBtn = document.getElementById('lock-btn');
        if (lockBtn) {
            // lockStatus: 1 = unlocked, 2 = locked (usually)
            const isLocked = data.lockStatus === 2 || data.lockStatus === 3 || data.lockStatus === 4;
            if (isLocked) {
                lockBtn.style.color = '#ff3333';
                lockBtn.querySelector('svg').style.color = '#ff3333';
                lockBtn.querySelector('svg').classList.remove('fa-lock-open');
                lockBtn.querySelector('svg').classList.add('fa-lock');
            } else {
                lockBtn.style.color = '#b3ff00';
                lockBtn.querySelector('svg').style.color = '#b3ff00';
                lockBtn.querySelector('svg').classList.remove('fa-lock');
                lockBtn.querySelector('svg').classList.add('fa-lock-open');
            }

            // Sync car icons as well
            const doorIcons = document.querySelectorAll('.lock-icon i');
            doorIcons.forEach(icon => {
                if (isLocked) {
                    icon.style.color = '#ff3333';
                } else {
                    icon.style.color = '#b3ff00';
                }
            });
        }

        // Sync individual door open/closed status if needed
        if (data.doors) {
            const doors = document.querySelectorAll('.lock-icon');
            for (let i = 0; i < 6; i++) {
                if (doors[i] && data.doors[i.toString()]) {
                    doors[i].classList.add('open');
                    doors[i].querySelector('i').classList.remove('fa-lock');
                    doors[i].querySelector('i').classList.add('fa-lock-open');
                } else if (doors[i]) {
                    doors[i].classList.remove('open');
                    // Icon type handled by global lock sync, but ensure it's correct
                    if(data.lockStatus === 1) {
                         doors[i].querySelector('i').classList.remove('fa-lock');
                         doors[i].querySelector('i').classList.add('fa-lock-open');
                    } else {
                         doors[i].querySelector('i').classList.remove('fa-lock-open');
                         doors[i].querySelector('i').classList.add('fa-lock');
                    }
                }
            }
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

    // UI is optimistically updated by NUI but the update loop will overwrite it with actual state next tick
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
