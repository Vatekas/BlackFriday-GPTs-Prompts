document.addEventListener('DOMContentLoaded', () => {
    const phoneContainer = document.getElementById('phone-container');

    // Setup Steps Elements
    const step1 = document.getElementById('setup-step-1');
    const step2 = document.getElementById('setup-step-2');
    const step3 = document.getElementById('setup-step-3');

    // Step 1: Language
    const langBtn = document.getElementById('lang-lt-btn');

    // Step 2: PIN
    const keypadBtns = document.querySelectorAll('.keypad-btn:not(.empty)');
    const pinDots = document.querySelectorAll('.pin-dot');
    let currentPin = '';

    // Step 3: Theme
    const themeOptions = document.querySelectorAll('.theme-option');
    const finishBtn = document.getElementById('finish-setup-btn');
    let selectedTheme = null;

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
        // Reset Setup State on Open
        step1.classList.remove('hidden');
        step2.classList.add('hidden');
        step3.classList.add('hidden');
        currentPin = '';
        updatePinDisplay();
        selectedTheme = null;
        themeOptions.forEach(opt => opt.classList.remove('selected'));
        finishBtn.classList.add('hidden');
    }

    function closePhone() {
        phoneContainer.classList.add('hidden');
    }

    // --- STEP 1: Language Selection ---
    langBtn.addEventListener('click', () => {
        step1.classList.add('hidden');
        setTimeout(() => {
            step2.classList.remove('hidden');
        }, 50); // slight delay for smooth transition
    });

    // --- STEP 2: PIN Keypad ---
    keypadBtns.forEach(btn => {
        btn.addEventListener('click', () => {
            // Handle Delete
            if (btn.classList.contains('delete') || btn.querySelector('.fa-delete-left')) {
                if (currentPin.length > 0) {
                    currentPin = currentPin.slice(0, -1);
                }
            } else {
                // Handle Numbers
                if (currentPin.length < 4) {
                    currentPin += btn.textContent.trim();
                }
            }
            updatePinDisplay();

            // Auto-advance when 4 digits entered
            if (currentPin.length === 4) {
                setTimeout(() => {
                    step2.classList.add('hidden');
                    setTimeout(() => {
                        step3.classList.remove('hidden');
                    }, 50);
                }, 300); // slight delay to let user see the 4th dot fill
            }
        });
    });

    function updatePinDisplay() {
        pinDots.forEach((dot, index) => {
            if (index < currentPin.length) {
                dot.classList.add('filled');
            } else {
                dot.classList.remove('filled');
            }
        });
    }

    // --- STEP 3: Theme Selection ---
    themeOptions.forEach(option => {
        option.addEventListener('click', () => {
            themeOptions.forEach(opt => opt.classList.remove('selected'));
            option.classList.add('selected');
            selectedTheme = option.getAttribute('data-theme');
            finishBtn.classList.remove('hidden');
        });
    });

    // --- Home & Phone App Elements ---
    const homeScreen = document.getElementById('home-screen');
    const phoneAppScreen = document.getElementById('phone-app-screen');
    const setupContainer = document.getElementById('setup-container');
    const phoneAppBtn = document.getElementById('phone-app-btn');
    const shareNumberBtn = document.getElementById('share-number-btn');
    const myNameEl = document.getElementById('my-name');
    const myNumberEl = document.getElementById('my-number');

    // Call Elements
    const callScreen = document.getElementById('call-screen');
    const callerNameEl = document.getElementById('caller-name');
    const callStatusEl = document.getElementById('call-status');
    const answerCallBtn = document.getElementById('answer-call-btn');
    const endCallBtn = document.getElementById('end-call-btn');

    let isSetupComplete = false;
    let inCall = false;

    // Finish Setup -> Send data to Lua
    finishBtn.addEventListener('click', () => {
        fetch(`https://${GetParentResourceName()}/setupComplete`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({
                language: 'lt',
                pin: currentPin,
                theme: selectedTheme
            })
        });
    });

    // Handle Phone App Open
    phoneAppBtn.addEventListener('click', () => {
        homeScreen.classList.add('hidden');
        phoneAppScreen.classList.remove('hidden');
    });

    // Handle Share Number
    shareNumberBtn.addEventListener('click', () => {
        fetch(`https://${GetParentResourceName()}/shareNumber`, {
            method: 'POST',
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: JSON.stringify({})
        });
    });

    // Handle Incoming / Outgoing Call State (From Lua)
    window.addEventListener('message', (event) => {
        const item = event.data;
        if (item.action === "setupData") {
            if(item.name) myNameEl.textContent = item.name;
            if(item.number) myNumberEl.textContent = item.number;
            isSetupComplete = true;
            setupContainer.classList.add('hidden');
            homeScreen.classList.remove('hidden');
        } else if (item.action === "incomingCall") {
            phoneContainer.classList.remove('hidden');
            homeScreen.classList.add('hidden');
            phoneAppScreen.classList.add('hidden');
            setupContainer.classList.add('hidden');
            callScreen.classList.remove('hidden');
            callerNameEl.textContent = item.caller || "Unknown";
            callStatusEl.textContent = "Skambina...";
            answerCallBtn.style.display = "flex";
            inCall = false;
        } else if (item.action === "callAnswered") {
            callStatusEl.textContent = "Pokalbis vyksta";
            answerCallBtn.style.display = "none";
            inCall = true;
        } else if (item.action === "endCall") {
            callScreen.classList.add('hidden');
            if (isSetupComplete) {
                homeScreen.classList.remove('hidden');
            }
            inCall = false;
        }
    });

    // Call Actions
    answerCallBtn.addEventListener('click', () => {
        callStatusEl.textContent = "Sujungiama...";
        fetch(`https://${GetParentResourceName()}/answerCall`, {
            method: 'POST',
            headers: {'Content-Type': 'application/json; charset=UTF-8'}
        });
    });

    endCallBtn.addEventListener('click', () => {
        callScreen.classList.add('hidden');
        if (isSetupComplete) {
            homeScreen.classList.remove('hidden');
        }
        fetch(`https://${GetParentResourceName()}/endCall`, {
            method: 'POST',
            headers: {'Content-Type': 'application/json; charset=UTF-8'}
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
