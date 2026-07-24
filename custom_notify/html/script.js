window.addEventListener('message', function(event) {
    if (event.data.action === 'showNotification') {
        showNotification(event.data.message, event.data.type, event.data.title, event.data.duration);
    }
});

function showNotification(message, type, title, duration) {
    const container = document.getElementById('notification-container');
    const displayDuration = duration || 3500;

    // Make container visible if it was hidden
    container.style.left = '20px';

    const notification = document.createElement('div');
    notification.classList.add('notification', type);

    if (type === 'report') {
        notification.innerHTML = `
            <div class="report-header">
                <div class="report-icon">
                    <i class="fa-solid fa-ticket"></i>
                </div>
                <div class="report-title">${title || 'Pagalba'}</div>
            </div>
            <div class="report-message">${message}</div>
            <div class="report-pattern"></div>
        `;
    } else if (type === 'progress') {
        notification.innerHTML = `
            <div class="progress-top">
                <div class="progress-message">${message}</div>
                <div class="progress-percent">100%</div>
            </div>
            <div class="progress-bar-bg">
                <div class="progress-bar-fill"></div>
            </div>
        `;
    } else {
        // Standard success type
        notification.innerHTML = `
            <div class="icon-container">
                <i class="fa-regular fa-circle-check"></i>
            </div>
            <div class="message-content">${message}</div>
        `;
    }

    container.appendChild(notification);

    // Trigger reflow for animation
    void notification.offsetWidth;

    // Add show class to animate in
    notification.classList.add('show');

    // Handle progress bar animation if type is progress
    if (type === 'progress') {
        const fill = notification.querySelector('.progress-bar-fill');
        const percentText = notification.querySelector('.progress-percent');

        // Ensure styles apply before transition
        setTimeout(() => {
            fill.style.transition = `width ${displayDuration}ms linear`;
            fill.style.width = '0%';
        }, 50);

        let startTime = Date.now();
        let interval = setInterval(() => {
            let elapsed = Date.now() - startTime;
            let remaining = Math.max(0, 1 - (elapsed / displayDuration));
            let currentPercent = Math.round(remaining * 100);

            if (percentText) {
                percentText.innerText = currentPercent + '%';
            }

            if (elapsed >= displayDuration) {
                clearInterval(interval);
            }
        }, 50);
    }

    // Remove notification after specified duration
    setTimeout(() => {
        notification.classList.remove('show');

        // Wait for slide-out animation to finish before removing from DOM
        setTimeout(() => {
            notification.remove();

            // Hide container if no notifications left
            if (container.children.length === 0) {
                 container.style.left = '-400px';
            }
        }, 400);
    }, displayDuration);
}

// For testing in browser without FiveM
// window.onload = () => {
//     setTimeout(() => {
//         showNotification("Atrakintos durys", "success");
//     }, 500);
// };
