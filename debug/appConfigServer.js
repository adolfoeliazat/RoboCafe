#!/usr/bin/env node

var WebSocketServer = require('ws').Server
var wss = new WebSocketServer({ port: 8008 });

wss.on('connection', function connection(ws) {
	ws.on('message', function incoming(message) {
		console.log('received: %s', message);
	});

	setTimeout(function() {
		ws.send(JSON.stringify({
			setUserDefaults: {
				item1: "Candy",
				item2: "Snacks",
				item3: "Beer!"
			},
			setCafeStatusWSURL: "ws://141.212.11.214:8081",
			setLocationWSURL: "ws://141.212.11.214:8082"
		}));
		console.log('sent ' + Date.now());
	}, 2000);
});
