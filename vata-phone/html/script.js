document.addEventListener('DOMContentLoaded', () => {
    const phoneContainer = document.getElementById('phone-container');
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
    }

    function closePhone() {
        phoneContainer.classList.add('hidden');
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
