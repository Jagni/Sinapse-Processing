# Sinapse

## Iniciando conexão WebRTC

- Instale as dependências. Execute o comando abaixo na pasta `webrtc_client`:
```
npm install
```
- Inicie o servidor websocket do Processing (`kinect_prototype\kinect_prototype.pde`)
- Inicie o `signal-server.js` e o `server.js`
```
node signal-server.js
node server.js
```

- Acesse `http://localhost:3000` e clique em `Connect`.

_Os clientes tentarão se conectar via WebSocket em `ws://localhost:8080`, esperando pela transmissão de base64 capturados do canvas do Processing._

### TODO
- Restringir número de clientes
- Proteção por senha/chave
- Recuperação se o servidor cair
