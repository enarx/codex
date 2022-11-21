function init() {
    var inactiveMessage = "Server is down"
    chatPopup = document.querySelector(".chat-popup")
    chatSubmit = document.querySelector(".chat-submit")
    chatHeader = document.querySelector(".chat-header")
    chatArea = document.querySelector(".chat-area")
    chatInput = document.querySelector(".chat-input")
    root = document.documentElement;
    chatPopup.style.display = "flex"
    var host = "http://localhost:8080"

    chatSubmit.addEventListener("click", () => {
        let userResponse = chatInput.value.trim();
        if (userResponse !== "") {
            setUserResponse();
            send(userResponse)
        }
    })
}

function userResponseBtn(e) {
    send(e.value);
}

// to submit user input when he presses enter
function givenUserInput(e) {
    if (e.keyCode == 13) {
        let userResponse = chatInput.value.trim();
        if (userResponse !== "") {
            setUserResponse()
            send(userResponse)
        }
    }
}

// to display user message on UI
function setUserResponse() {
    let userInput = chatInput.value;
    if (userInput) {
        let temp = `<div class="user-msg"><span class = "msg">${userInput}</span></div>`
        chatArea.innerHTML += temp;
        chatInput.value = ""
    } else {
        chatInput.disabled = false;
    }
    scrollToBottomOfResults();
}

function scrollToBottomOfResults() {
    chatArea.scrollTop = chatArea.scrollHeight;
}

function send(message) {
    chatInput.type = "text"
    passwordInput = false;
    chatInput.focus();
    console.log("User Message:", message)
    $.ajax({
        url: host,
        method: 'PUT',
        data: {
            message: message
        }
    });
    chatInput.focus();
}

function createChat() {

    host = "http://localhost:8080";
    init()
    const msg = document.querySelector(".msg");
    msg.innerText = "Welcome to Enarx Chat! Send a message to an Enarx Keep below:";

    const botTitle = document.querySelector(".bot-title");
    botTitle.innerText = "Enarx Chat";
}

createChat();