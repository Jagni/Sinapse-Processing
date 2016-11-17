# Sinapse

## Iniciando conexão WebRTC
_(Versão de testes)_

- Instale as dependências. Execute o comando abaixo na pasta `webrtc_client`:
```
npm install
```
- Inicie o servidor websocket do Processing (`kinect_prototype\kinect_prototype.pde`).
- Inicie o `signal-server.js` e o `server.js`:
```
node signal-server.js
node server.js
```
- Acesse `http://localhost:3000` em duas abas diferentes e clique em `Connect`.
- Um canal de comunicação é aberto e é possível troca de dados.

_Os clientes tentarão se conectar via WebSocket em `ws://localhost:8080`, esperando pela transmissão de base64 capturados do canvas do Processing._

### TODO
- Restringir número de clientes
- Proteção por senha/chave
- Recuperação se o servidor cair
