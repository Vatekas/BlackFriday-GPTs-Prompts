let isUIOpen = false;
let isAdmin = false;

window.addEventListener('message', function(event) {
    let data = event.data;

    if (data.type === 'ui') {
        isAdmin = data.isAdmin || false;
        if (data.status) {
            document.getElementById('app').style.display = 'flex';
            isUIOpen = true;
        } else {
            document.getElementById('app').style.display = 'none';
            isUIOpen = false;
        }
    } else if (data.type === 'newMessage') {
        const msg = data.messageData;
        appendMessage(msg.name || msg.sender, msg.message, msg.role, msg.time, msg.playerId);
    } else if (data.type === 'systemMessage') {
        appendSystemMessage(data.message);
    } else if (data.type === 'clearChat') {
        document.getElementById('chat-area').innerHTML = '';
    }
});

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape' && isUIOpen) {
        closeUI();
    }
});

document.getElementById('close-app-btn').addEventListener('click', closeUI);

function closeUI() {
    document.getElementById('app').style.display = 'none';
    isUIOpen = false;
    fetch(`https://${GetParentResourceName()}/closeUI`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}

document.getElementById('send-btn').addEventListener('click', sendMessage);
document.getElementById('message-input').addEventListener('keypress', function(e) {
    if (e.key === 'Enter') {
        sendMessage();
    }
});

function sendMessage() {
    let input = document.getElementById('message-input');
    let message = input.value.trim();

    if (message.length > 0) {
        fetch(`https://${GetParentResourceName()}/sendMessage`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                message: message
            })
        });
        input.value = '';
    }
}

document.getElementById('btn-close-ticket').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/closeTicket`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
});

document.getElementById('btn-other-admin').addEventListener('click', function() {
    console.log("Request other admin clicked");
});

document.getElementById('btn-unresolved').addEventListener('click', function() {
    console.log("Unresolved problem clicked");
});

function appendMessage(senderName, messageText, role, timeStr, playerId) {
    const chatArea = document.getElementById('chat-area');
    const msgDiv = document.createElement('div');
    msgDiv.classList.add('message');
    msgDiv.classList.add(role === 'admin' ? 'admin-message' : 'user-message');

    const roleBadgeDiv = document.createElement('div');
    roleBadgeDiv.classList.add('role');
    if (role === 'admin') {
        roleBadgeDiv.classList.add('badge-admin');
        roleBadgeDiv.textContent = 'AD';
    } else {
        roleBadgeDiv.classList.add('badge-user');
        roleBadgeDiv.textContent = 'US';
    }

    const msgContentDiv = document.createElement('div');
    msgContentDiv.classList.add('msg-content');

    const msgHeaderDiv = document.createElement('div');
    msgHeaderDiv.classList.add('msg-header');

    const nameSpan = document.createElement('span');
    nameSpan.classList.add('name');
    nameSpan.textContent = (senderName || 'Nežinomas') + (playerId ? ` [${playerId}]` : '');

    const badgeSpan = document.createElement('span');
    if (role === 'admin') {
        badgeSpan.classList.add('role-badge');
        badgeSpan.textContent = 'ADMINISTRATORIUS';
    } else {
        badgeSpan.classList.add('role-badge-small');
        badgeSpan.textContent = role === 'self' ? 'JŪS' : 'ŽAIDĖJAS';
    }

    msgHeaderDiv.appendChild(nameSpan);
    msgHeaderDiv.appendChild(badgeSpan);

    const msgTextDiv = document.createElement('div');
    msgTextDiv.classList.add('msg-text');
    msgTextDiv.textContent = messageText;

    const msgTimeDiv = document.createElement('div');
    msgTimeDiv.classList.add('msg-time');
    msgTimeDiv.textContent = timeStr || 'ką tik';

    msgContentDiv.appendChild(msgHeaderDiv);
    msgContentDiv.appendChild(msgTextDiv);
    msgContentDiv.appendChild(msgTimeDiv);

    msgDiv.appendChild(roleBadgeDiv);
    msgDiv.appendChild(msgContentDiv);

    chatArea.appendChild(msgDiv);
    chatArea.scrollTop = chatArea.scrollHeight;
}

function appendSystemMessage(messageText) {
    const chatArea = document.getElementById('chat-area');
    const sysDiv = document.createElement('div');
    sysDiv.classList.add('system-message');
    sysDiv.textContent = messageText;

    chatArea.appendChild(sysDiv);
    chatArea.scrollTop = chatArea.scrollHeight;
}
