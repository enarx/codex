function init() {

    //--------------------------- Important Variables----------------------------
    var inactiveMessage = "Server is down, Please contact the developer to activate it"
    chatPopup = document.querySelector(".chat-popup")
    chatBtn = document.querySelector(".chat-btn")
    chatSubmit = document.querySelector(".chat-submit")
    chatHeader = document.querySelector(".chat-header")
    chatArea = document.querySelector(".chat-area")
    chatInput = document.querySelector(".chat-input")
    expandWindow = document.querySelector(".expand-chat-window")
    root = document.documentElement;
    chatPopup.style.display = "none"
    var host = "http://localhost:8080"


    //------------------------ ChatBot Toggler -------------------------

    chatBtn.addEventListener("click", () => {

        mobileDevice = !detectMob()
        if (chatPopup.style.display == "none" && mobileDevice) {
            chatPopup.style.display = "flex"
            chatInput.focus();
            chatBtn.innerHTML = `<i class='material-icons'>close</i>`
        } else if (mobileDevice) {
            chatPopup.style.display = "none"
            chatBtn.innerHTML = `<i class='material-icons'>chat</i>`
        } else {
            mobileView()
        }
    })

    chatSubmit.addEventListener("click", () => {
        let userResponse = chatInput.value.trim();
        if (userResponse !== "") {
            setUserResponse();
            send(userResponse)
        }
    })
}

// end of init function

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

/***************************************************************
Frontend Part Completed
****************************************************************/

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

function mobileView() {
    $('.chat-popup').width($(window).width());

    if (chatPopup.style.display == "none") {
        chatPopup.style.display = "flex"
            // chatInput.focus();
        chatBtn.style.display = "none"
        chatPopup.style.bottom = "0"
        chatPopup.style.right = "0"
            // chatPopup.style.transition = "none"
        expandWindow.innerHTML = `<i class='material-icons'>close</i>`
    }
}

function detectMob() {
    return ((window.innerHeight <= 800) && (window.innerWidth <= 600));
}

function createChatBot() {

    host = "http://localhost:8080";
    init()
    const msg = document.querySelector(".msg");
    msg.innerText = "Welcome to Enarx Chat!";

    const botTitle = document.querySelector(".bot-title");
    botTitle.innerText = "Enarx Chat";
}

createChatBot();