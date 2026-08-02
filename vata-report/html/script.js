document.addEventListener('DOMContentLoaded', () => {
    const app = document.getElementById('app');
    const sendBtn = document.getElementById('send-btn');
    const messageInput = document.getElementById('message-input');
    const chatArea = document.getElementById('chat-area');

    // Handle messages from Lua
    window.addEventListener('message', (event) => {
        const item = event.data;
        if (item.type === 'ui') {
            if (item.status === true) {
                app.style.display = 'flex';
                // optionally scroll to bottom
                chatArea.scrollTop = chatArea.scrollHeight;
            } else {
                app.style.display = 'none';
            }
        } else if (item.type === 'newMessage') {
            appendMessage(item.messageData);
        }
    });

    // Close on Escape Key
    document.addEventListener('keyup', (e) => {
        if (e.key === 'Escape') {
            closeUI();
        }
    });

    // Send Button Event
    sendBtn.addEventListener('click', () => {
        sendMessage();
    });

    // Send on Enter Key
    messageInput.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') {
            sendMessage();
        }
    });

    function closeUI() {
        app.style.display = 'none';
        fetch(`https://${GetParentResourceName()}/closeUI`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        });
    }

    function sendMessage() {
        const text = messageInput.value.trim();
        if (text === '') return;

        fetch(`https://${GetParentResourceName()}/sendMessage`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({ message: text })
        });

        messageInput.value = '';
    }

    function appendMessage(data) {
        const timeStr = "prieš kelias akimirkas";

        const messageDiv = document.createElement('div');
        messageDiv.className = `message ${data.isAdmin ? 'admin-message' : 'user-message'}`;

        const avatarDiv = document.createElement('div');
        avatarDiv.className = 'avatar';
        const img = document.createElement('img');
        img.src = data.isAdmin ? 'img/avatar2.png' : 'img/avatar1.png';
        const safeName = encodeURIComponent(data.name || 'User');
        img.onerror = function() {
            this.src = `https://ui-avatars.com/api/?name=${safeName}&background=${data.isAdmin ? 'f0c000' : '333'}&color=${data.isAdmin ? '000' : 'fff'}`;
        };
        avatarDiv.appendChild(img);

        const msgContent = document.createElement('div');
        msgContent.className = 'msg-content';

        const msgHeader = document.createElement('div');
        msgHeader.className = 'msg-header';

        const nameSpan = document.createElement('span');
        nameSpan.className = 'name';
        nameSpan.textContent = data.name; // Secure: uses textContent

        const roleSpan = document.createElement('span');
        roleSpan.className = `role ${data.isAdmin ? 'badge-admin' : 'badge-user'}`;
        roleSpan.textContent = data.isAdmin ? 'Administratorius' : 'Jūs';

        msgHeader.appendChild(nameSpan);
        msgHeader.appendChild(roleSpan);

        const textDiv = document.createElement('div');
        textDiv.className = 'msg-text';
        textDiv.textContent = data.message; // Secure: uses textContent

        const timeDiv = document.createElement('div');
        timeDiv.className = 'msg-time';
        timeDiv.textContent = timeStr;

        msgContent.appendChild(msgHeader);
        msgContent.appendChild(textDiv);
        msgContent.appendChild(timeDiv);

        messageDiv.appendChild(avatarDiv);
        messageDiv.appendChild(msgContent);

        chatArea.appendChild(messageDiv);
        chatArea.scrollTop = chatArea.scrollHeight;
    }

    // Action buttons (dummy functionality for now)
    const actionBtns = document.querySelectorAll('.action-btn');
    actionBtns.forEach(btn => {
        btn.addEventListener('click', (e) => {
            if(e.target.classList.contains('danger')) {
                 fetch(`https://${GetParentResourceName()}/closeTicket`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
                    body: JSON.stringify({})
                });
                closeUI();
            } else {
                 console.log("Action triggered: " + e.target.innerText);
            }
        });
    });
});