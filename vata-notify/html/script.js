document.addEventListener('DOMContentLoaded', () => {
    const container = document.getElementById('notify-container');

    const icons = {
        success: `<svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10" fill="#2ed573"/><path d="M8.5 12.5L10.8 15L15.5 9.5" stroke="#0d0e0f" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/></svg>`,
        error: `<svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10" fill="#ff4757"/><path d="M9 9L15 15M15 9L9 15" stroke="#ffffff" stroke-width="2.5" stroke-linecap="round"/></svg>`,
        warning: `<svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10" fill="#ffa502"/><path d="M12 7.5V13M12 16.5H12.01" stroke="#0d0e0f" stroke-width="2.5" stroke-linecap="round"/></svg>`,
        info: `<svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10" fill="#387df6"/><text x="11.5" y="16.2" text-anchor="middle" font-family="Georgia, serif" font-style="italic" font-weight="900" font-size="14.5" fill="#0d0e0f">i</text></svg>`
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
        header.appendChild(iconWrapper);

        if (data.title && data.title.trim() !== '') {
            const titleEl = document.createElement('div');
            titleEl.className = 'notification-title';
            titleEl.textContent = data.title;
            header.appendChild(titleEl);
            content.appendChild(header);

            if (data.text && data.text.trim() !== '') {
                const textEl = document.createElement('div');
                textEl.className = 'notification-text';
                textEl.textContent = data.text;
                content.appendChild(textEl);
            }
        } else {
            const textEl = document.createElement('div');
            textEl.className = 'notification-title';
            textEl.textContent = data.text || '';
            header.appendChild(textEl);
            content.appendChild(header);
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
