document.addEventListener('DOMContentLoaded', () => {
    const phoneContainer = document.getElementById('phone-container');
    const bootScreen = document.getElementById('boot-screen');
    const setupScreen = document.getElementById('setup-screen');
    const langButtons = document.querySelectorAll('.lang-btn');

    // Handle NUI Messages from Lua
    window.addEventListener('message', (event) => {
        const item = event.data;
        if (item.action === "togglePhone") {
            if (item.state) {
                openPhone();
            } else {
                closePhone();
            }
        }
    });

    function openPhone() {
        phoneContainer.classList.remove('hidden');

        // Reset screens
        bootScreen.classList.remove('hidden');
        bootScreen.style.opacity = '1';
        setupScreen.classList.add('hidden');
        setupScreen.style.opacity = '0';

        // Simulate boot sequence
        setTimeout(() => {
            // Fade out boot screen
            bootScreen.style.opacity = '0';

            setTimeout(() => {
                bootScreen.classList.add('hidden');

                // Fade in setup screen
                setupScreen.classList.remove('hidden');
                // Trigger reflow
                void setupScreen.offsetWidth;
                setupScreen.style.opacity = '1';
            }, 500); // Wait for fade out

        }, 2000); // Show LUNAX logo for 2 seconds
    }

    function closePhone() {
        phoneContainer.classList.add('hidden');
        // Reset state
        bootScreen.classList.remove('hidden');
        bootScreen.style.opacity = '1';
        setupScreen.classList.add('hidden');
        setupScreen.style.opacity = '0';
    }

    // Handle language selection
    langButtons.forEach(btn => {
        btn.addEventListener('click', () => {
            const selectedLang = btn.getAttribute('data-lang');

            // Send callback to Lua
            fetch(`https://${GetParentResourceName()}/languageSelected`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({
                    language: selectedLang
                })
            }).catch(e => console.log('Error sending callback:', e));
        });
    });

    // Close phone on Escape key
    document.onkeyup = function (data) {
        if (data.which == 27) { // Escape key
            fetch(`https://${GetParentResourceName()}/closePhone`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({})
            }).catch(e => console.log('Error sending callback:', e));
        }
    };
});
