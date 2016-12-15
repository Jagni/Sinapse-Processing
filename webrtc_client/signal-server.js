require('dotenv').config();
const fs = require('fs');
const bcrypt = require('bcrypt');
const server = require('http').createServer();
const port = 7000;

const io = require('socket.io')(server);

let firstClient;
let secondClient;
let clients = [];

/*
** Gerar uma senha usando bcrypt
*/
// const saltRounds = 10;
// const senha = 'senha';
// bcrypt.genSalt(saltRounds, function(err, salt) {
//   bcrypt.hash(senha, salt, function(err, hash) {
//     fs.writeFile(`${__dirname}/.env`, `KEY=${hash}`, (err) => console.log(err));
//   });
// });

io.on('connection', (client) => {
  console.log(`>>> ${client.id} se conectou`);

  client.emit('set-id', client.id);

  client.on('try-connection', (password) => {
    bcrypt.compare(password, process.env.KEY, function(err, match) {
      if(match) {
        if(!firstClient) {
          firstClient = { id: client.id, instance: client };
          clients.push(firstClient);
          
          client.emit('got-first-client');
          return;
        }
        else if(!secondClient) {
          secondClient = { id: client.id, instance: client };
          clients.push(secondClient);

          io.emit('end-wait');
          client.emit('got-second-client');
          return;
        }
        
        let reason = 'Três clientes já é demais.';
        client.emit('refuse-connection', reason);
      }
      else {
        let reason;

        if(!match) reason = 'Essa não é a senha...';
        else reason = 'Três clientes já é demais.';

        client.emit('refuse-connection', reason);
      }
    });
  });

  client.on('set-remote-from-offer', (offer) => {
    log(client.id, offer);
    io.emit('set-remote-from-offer', client.id, offer);
  });

  client.on('set-remote-from-answer', (answer) => {
    log(client.id, answer);
    io.emit('set-remote-from-answer', client.id, answer);
  });

  client.on('set-ice-candidate', (candidate) => {
    log(client.id, candidate);
    io.emit('set-ice-candidate', client.id, candidate);
  });

  client.on('disconnect', () => {
    if(firstClient && client.id == firstClient.id) firstClient = undefined;
    if(secondClient && client.id == secondClient.id) secondClient = undefined;
    
    clients.forEach((c) => {
      c.instance.emit('disconnection');
    });

    clients.filter(c => c.id != client.id);
  });
});

function log(id, value) {
  console.log(`==> Event\n`);
  console.log(` => Name:\n`);
  console.log(`   > Set remote from offer\n`);
  console.log(` => From:\n`);
  console.log(`   > ${id}\n`);
  console.log(` => Value:\n`);
  console.log(`   > ${JSON.stringify(value)}\n`);
  console.log(`\n`);
}

server.listen(port, console.log(`Server started on http://localhost:${port}`));