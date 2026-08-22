document.addEventListener('DOMContentLoaded', () => {
    const container = document.getElementById('notify-container');

    const icons = {
        success: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><polyline points="9 12 11 14 15 10"></polyline></svg>`,
        error: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="15" y1="9" x2="9" y2="15"></line><line x1="9" y1="9" x2="15" y2="15"></line></svg>`,
        warning: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>`,
        info: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line></svg>`
    };

    window.addEventListener('message', (event) => {
        const item = event.data;
        if (item && item.action === 'notify') {
            createNotification(item.data);
        }
    });

    function createNotification(data) {
        const position = data.position || 'top-right';
        container.className = `notify-container ${position}`;

        const type = data.type || 'info';
        const notification = document.createElement('div');
        notification.className = `notification type-${type}`;

        const content = document.createElement('div');
        content.className = 'notification-content';

        const header = document.createElement('div');
        header.className = 'notification-header';

        const iconWrapper = document.createElement('div');
        iconWrapper.className = 'icon-wrapper';
        iconWrapper.innerHTML = icons[type] || icons.info;

        const titleEl = document.createElement('div');
        titleEl.className = 'notification-title';
        titleEl.textContent = data.title || '';

        header.appendChild(iconWrapper);
        header.appendChild(titleEl);
        content.appendChild(header);

        if (data.text && data.text.trim() !== '') {
            const textEl = document.createElement('div');
            textEl.className = 'notification-text';
            textEl.textContent = data.text;
            content.appendChild(textEl);
        }

        notification.appendChild(content);
        container.appendChild(notification);

        const duration = data.duration || 5000;
        setTimeout(() => {
            notification.classList.add('removing');
            notification.addEventListener('animationend', () => {
                if (notification.parentNode) {
                    notification.parentNode.removeChild(notification);
                }
            });
        }, duration);
    }
});
