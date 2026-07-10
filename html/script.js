// Listen for message events from FiveM client scripts
window.addEventListener('message', function(event) {
    const data = event.data;

    // HUD Update Event
    if (data.action === 'updateHud') {
        // Update Player ID
        if (data.id !== undefined) {
            document.getElementById('player-id').innerText = data.id;
        }

        // Update Time
        if (data.time !== undefined) {
            document.getElementById('server-time').innerText = data.time;
        }

        // Update Job
        if (data.job !== undefined) {
            document.getElementById('player-job').innerText = data.job;
        }

        // Update Cash
        if (data.cash !== undefined) {
            document.getElementById('player-cash').innerText = formatCurrency(data.cash);
        }

        // Update Bank
        if (data.bank !== undefined) {
            document.getElementById('player-bank').innerText = formatCurrency(data.bank);
        }

        // Update Dirty Money & Visibility
        if (data.dirty !== undefined) {
            document.getElementById('player-dirty').innerText = formatCurrency(data.dirty);

            const dirtyRow = document.getElementById('dirty-money-row');
            if (data.hideDirty && data.dirty <= 0) {
                dirtyRow.classList.add('hidden');
            } else {
                dirtyRow.classList.remove('hidden');
            }
        }

        // Update Voice Level / Range (1, 2, 3)
        if (data.voiceRange !== undefined) {
            const fillElement = document.getElementById('voice-level-fill');
            const percent = (data.voiceRange / (data.voiceMax || 3)) * 100;
            fillElement.style.height = `${percent}%`;

            if (data.voiceColor) {
                fillElement.style.backgroundColor = data.voiceColor;
            } else {
                fillElement.style.backgroundColor = '#ffffff';
            }
        }

        // Update Talking State
        if (data.talking !== undefined) {
            const waves = document.getElementById('sound-waves');
            const micSvg = document.getElementById('mic-svg');

            if (data.talking) {
                waves.classList.add('talking');
                micSvg.classList.add('talking');
                micSvg.classList.remove('muted');
                micSvg.style.color = '#4ade80'; // Green while talking
            } else {
                waves.classList.remove('talking');
                micSvg.classList.remove('talking');
                micSvg.classList.add('muted');

                if (data.micMuted) {
                    micSvg.style.color = '#e53e3e'; // Red if hardware muted
                } else {
                    micSvg.style.color = ''; // Default grey-white
                }
            }
        }
    }

    // Speedometer Update Event (Dual Outer Arcs style)
    if (data.action === 'updateSpeedometer') {
        const speedo = document.getElementById('speedometer');
        if (data.show) {
            speedo.classList.remove('speedo-hidden');

            // Update Speed
            if (data.speed !== undefined) {
                document.getElementById('speedo-val').innerText = Math.round(data.speed);
            }

            // Update Gear
            if (data.gear !== undefined) {
                document.getElementById('speedo-gear').innerText = data.gear;
            }

            // Update RPM Ring (r=40, active arc is 188 units, full is 251)
            if (data.rpm !== undefined) {
                const fill = document.getElementById('rpm-fill');
                const activeLength = data.rpm * 188;
                fill.style.strokeDasharray = `${activeLength} 251`;
            }

            // Update Fuel (r=46, active arc is 88 units, full is 289)
            if (data.fuel !== undefined) {
                const fuelFill = document.getElementById('fuel-fill');
                const activeLength = (data.fuel / 100) * 88;
                fuelFill.style.strokeDasharray = `${activeLength} 289`;

                // Alert blinking if fuel < 20%
                const fuelIcon = document.getElementById('speedo-fuel-icon');
                if (data.fuel < 20) {
                    fuelIcon.classList.add('warning');
                } else {
                    fuelIcon.classList.remove('warning');
                }
            }

            // Update Engine Health (r=46, active arc is 88 units, full is 289)
            if (data.engine !== undefined) {
                const engineFill = document.getElementById('engine-fill');
                const enginePct = Math.max(0, Math.min(100, data.engine / 10)); // Convert 0-1000 to percentage
                const activeLength = (enginePct / 100) * 88;
                engineFill.style.strokeDasharray = `${activeLength} 289`;

                const engineIcon = document.getElementById('speedo-engine-icon');
                engineFill.classList.remove('warning', 'danger');

                if (data.engine < 400) { // heavily damaged (red)
                    engineFill.classList.add('danger');
                    engineIcon.classList.add('warning');
                } else if (data.engine < 750) { // moderately damaged (orange)
                    engineFill.classList.add('warning');
                    engineIcon.classList.add('warning');
                } else { // healthy (light blue)
                    engineIcon.classList.remove('warning');
                }
            }

            // Update Odometer (padded with zeroes)
            if (data.odo !== undefined) {
                const paddedOdo = String(Math.round(data.odo)).padStart(6, '0');
                document.getElementById('speedo-odo').innerText = `${paddedOdo} KM`;
            }
        } else {
            speedo.classList.add('speedo-hidden');
        }
    }

    // Location HUD Update Event
    if (data.action === 'updateLocation') {
        const hud = document.getElementById('location-hud');

        if (data.show) {
            hud.classList.remove('location-hidden');

            // Update text elements
            if (data.direction !== undefined) {
                document.getElementById('loc-direction').innerText = data.direction;
            }
            if (data.street !== undefined) {
                document.getElementById('loc-street').innerText = data.street;
            }
            if (data.details !== undefined) {
                document.getElementById('loc-details').innerText = data.details;
            }
        } else {
            hud.classList.add('location-hidden');
        }
    }
});

// Helper to format currency numbers with commas (e.g., 1000000 -> $1,000,000)
function formatCurrency(amount) {
    const formatter = new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD',
        minimumFractionDigits: 0,
        maximumFractionDigits: 0
    });
    return formatter.format(amount);
}
