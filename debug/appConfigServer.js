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
				item2: "Gummy Bears",
				item3: "Drinks"
			},
			setALPSWSURL: "ws://169.229.86.245:30005",
			setCafeStatusWSURL: "ws://169.229.86.245:8081",
			setLocationWSURL: "ws://169.229.86.245:8082"
		}), function ack(error) {
			console.log(error);
		});
		var now = new Date().toISOString()
		console.log('sent ' + now);
	}, 2000);
});
