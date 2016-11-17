var connectButton = document.querySelector('#connect');
connectButton.onclick = connect;

var canvas = document.querySelector('canvas');
var context = canvas.getContext('2d');
var image = new Image();
image.onload = () => {
  canvas.width = image.width;
  canvas.height = image.height;

  context.clearRect(0, 0, canvas.width, canvas.height);
  context.drawImage(image, 0, 0);
}

var conn = new RTCPeerConnection(null);
var receiveChannel;

conn.ondatachannel = receiveChannelCallback;

var sendChannel = conn.createDataChannel("sendChannel");
sendChannel.onopen = handleSendChannelStatusChange;
sendChannel.onclose = handleSendChannelStatusChange;

conn.onicecandidate = e => {
  if(e.candidate) {
    socket.emit('set-ice-candidate', e.candidate);
  }
};

var ws = new WebSocket('ws://localhost:8080/');
ws.onmessage = (message) => {
  if(sendChannel && sendChannel.readyState == 'open') {
    sendChannel.send(message.data);
  }
}

var socket = io('localhost:7000');

socket.on('set-remote-from-offer', (id, offer) => {
  connectButton.disabled = true;

  if(id == socket.id) return;

  conn.setRemoteDescription(offer)
    .catch(err => console.log(err));

  conn.createAnswer()
    .then(answer => {
      conn.setLocalDescription(answer)
        .catch(err => console.log(err));

      socket.emit('set-remote-from-answer', answer);
    })
    .catch(err => console.log(err));
});

socket.on('set-remote-from-answer', (id, answer) => {
  if(id == socket.id) return;

  conn.setRemoteDescription(answer)
    .catch(err => console.log(err));
});

socket.on('set-ice-candidate', (id, candidate) => {
  if(id == socket.id) return;

  conn.addIceCandidate(new RTCIceCandidate(candidate));
});

function connect() {
  connectButton.disabled = true;

  conn.createOffer()
    .then(offer => {
      conn.setLocalDescription(offer)
        .catch(err => console.log(err));
        
      socket.emit('set-remote-from-offer', offer);
    })
}

function handleCreateDescriptionError() {}

function handleSendChannelStatusChange() {
  if (sendChannel) {
    var state = sendChannel.readyState;
  
    if (state === "open") {
    }
  }
}

function receiveChannelCallback(event) {
  receiveChannel = event.channel;
  receiveChannel.onmessage = (e) => {
    image.src = `data:image/png;base64,${e.data}`;
  }
  receiveChannel.onopen = () => console.log('status');
  receiveChannel.onclose = () => console.log('status');
}