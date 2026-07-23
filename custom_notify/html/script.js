window.addEventListener('message', function(event) {
    if (event.data.action === 'showNotification') {
        showNotification(event.data.message, event.data.type);
    }
});

function showNotification(message, type) {
    const container = document.getElementById('notification-container');

    // Make container visible if it was hidden
    container.style.right = '20px';

    const notification = document.createElement('div');
    notification.classList.add('notification', type);

    let iconHtml = '';
    if (type === 'success') {
        iconHtml = '<i class="fa-regular fa-circle-check"></i>';
    } else {
        // Fallback for other types if needed later
        iconHtml = '<i class="fa-solid fa-info-circle"></i>';
    }

    notification.innerHTML = `
        <div class="icon-container">
            ${iconHtml}
        </div>
        <div class="message-content">
            ${message}
        </div>
    `;

    container.appendChild(notification);

    // Trigger reflow for animation
    void notification.offsetWidth;

    // Add show class to animate in
    notification.classList.add('show');

    // Remove notification after 3.5 seconds
    setTimeout(() => {
        notification.classList.remove('show');

        // Wait for animation to finish before removing from DOM
        setTimeout(() => {
            notification.remove();

            // Hide container if no notifications left
            if (container.children.length === 0) {
                 container.style.right = '-400px';
            }
        }, 400);
    }, 3500);
}

// For testing in browser without FiveM
// window.onload = () => {
//     setTimeout(() => {
//         showNotification("Atrakintos durys", "success");
//     }, 500);
// };
