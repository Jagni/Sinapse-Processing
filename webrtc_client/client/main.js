var connectForm = document.querySelector('form');
var connectInput = document.querySelector('input');
var errorMessage = document.querySelector('#errorMessage');

connectInput.focus();

connectForm.onsubmit = (e) => {
  e.preventDefault();
  socket.emit('try-connection', e.target[0].value);
};

var canvas = document.querySelector('canvas');
var gl = WebGLContext(canvas);
gl.init();

var conn = new RTCPeerConnection(null);
var receiveChannel;

conn.ondatachannel = receiveChannelCallback;

var sendChannel = conn.createDataChannel('sendChannel');
sendChannel.onopen = handleSendChannelStatusChange;
sendChannel.onclose = handleSendChannelStatusChange;

conn.onicecandidate = e => {
  if(e.candidate) {
    socket.emit('set-ice-candidate', e.candidate);
  }
};


let wsConn = new WebSocket('ws://localhost:8080/');
webSocketConnection(wsConn);

function webSocketConnection(conn) {
  let wsWasOpened = false;

  conn.onopen = () => { 
    wsWasOpened = true; 
    document.querySelector('.feedback').style.display = 'none';
    document.querySelector('.feedback').textContent = '';
  }

  conn.onclose = () => {
    setTimeout(() => webSocketConnection(wsConn), 1000);

    if(wsWasOpened) {
      canvas.width = 0;
      canvas.height = 0;
      document.querySelector('.feedback').style.display = 'block';
      document.querySelector('.feedback').textContent = 'Servidor do processing desconectado. Conecte-o e tente novamente.';
    }
  }

  conn.onmessage = (message) => {
    if(sendChannel && sendChannel.readyState == 'open') {
      console.log('sent');
      sendChannel.send(message.data);
    }
  }

  return conn;
}

var socket = io('https://sinapse.melros.co');

socket.on('disconnection', () => {
  canvas.width = 0;
  canvas.height = 0;
  document.querySelector('.feedback').style.display = 'block';
  document.querySelector('.feedback').textContent = 'Desconectado. Recarregue e tente novamente.';
});

socket.on('set-id', (id) => {
  document.querySelector('.client-id').textContent = id;
});

socket.on('got-first-client', () => {
  connectForm.style.display = 'none';
  document.querySelector('.feedback').style.display = 'block';
  document.querySelector('.feedback').textContent = 'Esperando...';
});

socket.on('end-wait', () => {
  document.querySelector('.feedback').style.display = 'none';
});

socket.on('got-second-client', () => {
  connect();
});

socket.on('refuse-connection', (reason) => {
  errorMessage.textContent = reason;
});

socket.on('set-remote-from-offer', (id, offer) => {
  connectForm.style.display = 'none';

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
  
    if (state === 'open') {
    }
  }
}

function receiveChannelCallback(event) {
  receiveChannel = event.channel;
  receiveChannel.onmessage = (e) => {
    // let image = new Image();

    // image.onload = () => {
    //   canvas.width = image.width;
    //   canvas.height = image.height;

    //   gl.draw(image);
    // }

    // image.src = `data:image/png;base64,${e.data}`;
    console.log('received');
    wsConn.send(e.data);
  }
  receiveChannel.onopen = () => console.log('Data channel was opened');
  receiveChannel.onclose = () => console.log('Data channel was closed');
}

function WebGLContext(canvas) {
  let sceneBuffer;
  let sceneTexture;
  let sceneTextureCoordBuffer;
  let shaderProgram;
  let textureCoordAttribute;
  let vertexPositionAttribute;

  let gl = canvas.getContext('webgl', {preserveDrawingBuffer: true}) || canvas.getContext('experimental-webgl', {preserveDrawingBuffer: true});

  function init() {
    if(!gl) return;

    gl.viewport(0, 0, canvas.width, canvas.height);

    gl.clearColor(1.0, 1.0, 1.0, 1.0);
    gl.clear(gl.COLOR_BUFFER_BIT);

    initShaders();
    initBuffers();
    initTextures();
  }

  function initShaders() {
    let fragmentShader = getShader(gl, 'shader-fs');
    let vertexShader = getShader(gl, 'shader-vs');

    shaderProgram = gl.createProgram();
    gl.attachShader(shaderProgram, vertexShader);
    gl.attachShader(shaderProgram, fragmentShader);
    gl.linkProgram(shaderProgram);

    if(!gl.getProgramParameter(shaderProgram, gl.LINK_STATUS)) {
      console.warn(`Unable to initialize the shader program: ${gl.getProgramInfoLog(shaderProgram)}`);
    }

    gl.useProgram(shaderProgram);

    vertexPositionAttribute = gl.getAttribLocation(shaderProgram, 'aVertexPosition');
    gl.enableVertexAttribArray(vertexPositionAttribute);

    textureCoordAttribute = gl.getAttribLocation(shaderProgram, 'aTextureCoord');
    gl.enableVertexAttribArray(textureCoordAttribute);
  }

  function getShader(gl, id, type) {
    let shaderScript, theSource, currentChild, shader;

    shaderScript = document.getElementById(id);

    if(!shaderScript) return null;

    theSource = shaderScript.text;

    if(!type) {
      switch(shaderScript.type) {
        case 'x-shader/x-fragment':
          type = gl.FRAGMENT_SHADER;
          break;
        case 'x-shader/x-vertex':
          type = gl.VERTEX_SHADER;
          break;
        default:
          return null;
      }
    }

    shader = gl.createShader(type);

    gl.shaderSource(shader, theSource);
    gl.compileShader(shader);
    if(!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
      console.warn(`An error occurred compiling the shaders: ${gl.getShaderInfoLog(shader)}`);
      gl.deleteShader(shader);
      return null;
    }

    return shader;
  }

  function initBuffers() {
    sceneBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, sceneBuffer);

    let vertices = [
      -1.0, -1.0,
      1.0, -1.0,
      -1.0,  1.0,
      -1.0,  1.0,
      1.0, -1.0,
      1.0,  1.0
    ];

    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW);

    sceneTextureCoordBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, sceneTextureCoordBuffer);

    let textureCoordinates = [
      0.0, 0.0,
      1.0, 0.0,
      0.0, 1.0,
      0.0, 1.0,
      1.0, 0.0,
      1.0, 1.0
    ];

    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(textureCoordinates), gl.STATIC_DRAW);
  }

  function initTextures() {
    sceneTexture = gl.createTexture();
    gl.bindTexture(gl.TEXTURE_2D, sceneTexture);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
  }

  function updateTexture(image) {
    gl.bindTexture(gl.TEXTURE_2D, sceneTexture);
    gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, true);
    gl.pixelStorei(gl.UNPACK_PREMULTIPLY_ALPHA_WEBGL, true);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, image);
  }

  function draw(image) {
    gl.viewport(0, 0, canvas.width, canvas.height);

    updateTexture(image);

    gl.clear(gl.COLOR_BUFFER_BIT);

    gl.bindBuffer(gl.ARRAY_BUFFER, sceneBuffer);
    gl.vertexAttribPointer(vertexPositionAttribute, 2, gl.FLOAT, false, 0, 0);

    gl.bindBuffer(gl.ARRAY_BUFFER, sceneTextureCoordBuffer);
    gl.vertexAttribPointer(textureCoordAttribute, 2, gl.FLOAT, false, 0, 0);

    gl.activeTexture(gl.TEXTURE0);
    gl.bindTexture(gl.TEXTURE_2D, sceneTexture);
    gl.uniform1i(gl.getUniformLocation(shaderProgram, 'uSampler'), 0);

    gl.drawArrays(gl.TRIANGLES, 0, 6);
  }

  return {
    init,
    draw
  }
}