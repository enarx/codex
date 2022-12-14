function init() {
    chatArea = document.querySelector(".chat-area")
    chatSubmit = document.querySelector(".chat-submit")
    chatHeader = document.querySelector(".chat-header")
    chatInput = document.querySelector(".chat-input")
    stopButton = document.querySelector(".stop-btn")
    root = document.documentElement;
    var host = "http://localhost:50010"

    chatSubmit.addEventListener("click", () => {
        let userResponse = chatInput.value.trim();
        if (userResponse !== "") {
            setUserResponse();
            send(userResponse, host)
        }
    })

    stopButton.addEventListener("click", () => {
        send("/04".trim(), host);
        chatInput.disabled = true;
    })
}

// end of init function

function userResponseBtn(e) {
    send(e.value);
}

// to submit user input when pressing enter
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

function send(message, host) {
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

init();