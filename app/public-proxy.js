// Forwards the public Railway port to PipesHub on 127.0.0.1:3000 (plain TCP, so
// HTTP, streaming and WebSockets pass through unchanged). The entrypoint starts it
// only after the first organization and administrator exist.
'use strict';
const net = require('net');
const listenPort = parseInt(process.env.PUBLIC_PORT || '8080', 10);
const targetPort = parseInt(process.env.INTERNAL_PORT || '3000', 10);
const server = net.createServer((client) => {
  const upstream = net.connect({ host: '127.0.0.1', port: targetPort });
  const close = () => { client.destroy(); upstream.destroy(); };
  client.on('error', close);
  upstream.on('error', close);
  client.on('close', close);
  upstream.on('close', close);
  client.pipe(upstream);
  upstream.pipe(client);
});
server.on('error', (err) => { console.error('public-proxy:', err.message); process.exit(1); });
server.listen({ port: listenPort, host: '::', ipv6Only: false }, () => {
  console.log(`public-proxy: listening on ${listenPort}, forwarding to 127.0.0.1:${targetPort}`);
});
