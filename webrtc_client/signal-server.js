var server = require('http').createServer();

var io = require('socket.io')(server);

io.on('connection', (client) => {
  console.log(`>>> ${client.id} se conectou`);

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
    
  });
});

function log(id, value) {
  console.log(`==> Event\n`);
  console.log(` > Name:\n`);
  console.log(` > Set remote from offer\n`);
  console.log(` > From:\n`);
  console.log(` > ${id}\n`);
  console.log(` > Value:\n`);
  console.log(` > ${JSON.stringify(value)}\n`);
  console.log(`\n`);
}

server.listen(7000);