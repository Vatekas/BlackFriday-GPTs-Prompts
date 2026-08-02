document.addEventListener('DOMContentLoaded', () => {
    const app = document.getElementById('app');
    const closeBtn = document.getElementById('close-btn');
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

    // Close Button Event
    closeBtn.addEventListener('click', () => {
        closeUI();
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
        // Simple append for demo purposes, in reality would use DOM manipulation or a framework
        // Depending on admin or user
        const timeStr = "prieš kelias akimirkas";
        const html = `
        <div class="message ${data.isAdmin ? 'admin-message' : 'user-message'}">
            <div class="avatar"><img src="${data.isAdmin ? 'img/avatar2.png' : 'img/avatar1.png'}" alt="" onerror="this.src='https://ui-avatars.com/api/?name=${data.name}&background=${data.isAdmin ? 'f0c000' : '333'}&color=${data.isAdmin ? '000' : 'fff'}'"></div>
            <div class="msg-content">
                <div class="msg-header">
                    <span class="name">${data.name}</span>
                    <span class="role ${data.isAdmin ? 'badge-admin' : 'badge-user'}">${data.isAdmin ? 'Administratorius' : 'Jūs'}</span>
                </div>
                <div class="msg-text">${data.message}</div>
                <div class="msg-time">${timeStr}</div>
            </div>
        </div>`;

        chatArea.insertAdjacentHTML('beforeend', html);
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