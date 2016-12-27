# Sinapse

## Iniciando conexão WebRTC
_(Versão de testes)_

- Instale as dependências. Execute o comando abaixo na pasta `webrtc`:
```
npm install
```
- Inicie o servidor websocket do Processing (`kinect_prototype\kinect_prototype.pde`).
- Inicie o `signal-server.js` e o `server.js`:
```
node signal-server.js
node server.js
```
- Acesse `http://localhost:3000` em duas abas diferentes e clique em `Conectar`.
- Um canal de comunicação é aberto e é possível troca de dados.

_Os clientes tentarão se conectar via WebSocket em `ws://localhost:8080/p5websocket`, esperando pela transmissão de base64 capturados do canvas do Processing._

### TODO
- [x] Restringir número de clientes
- [x] Recuperação se o servidor cair

## Interface (Processing)

Comando | Ação
------------ | -------------
Mover mouse | Rotacionar câmera
WASD | Deslizar câmera
Q | Salvar arquivo .obj
Z | Aumentar nível de detalhes
X | Diminuir nível de detalhes
C | Aumentar zoom
V | Diminuir zoom
L | Ativar/desativar linhas
T | Ativar/desativar triângulos
