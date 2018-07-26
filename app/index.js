var express = require("express");
var app = new express();
var port = process.env.APP_PORT;
var build = Date.now();
var gracefullyExiting = false;

app.use(function(req, res, next) {
  if (!gracefullyExiting) {
    return next();
  }
  res.setHeader("Connection", "close");
  return res.send(502, "Server is in the process of restarting.");
});

app.get("/", function(req, res) {
  res.send(port + " " + build + " " + Date.now());
});

var EventEmitter = require("events");
var Stream = new EventEmitter();

app.get("/sse", function(req, res) {
  res.sendFile(__dirname + "/sse.html");
});

app.get("/stream", function(req, res) {
  res.writeHead(200, {
    "Content-Type": "text/event-stream",
    "Cache-Control": "no-cache",
    "X-Accel-Buffering": "no",
    Connection: "keep-alive"
  });

  Stream.on("push", function(event, data) {
    res.write("event: message\n" + "data: " + JSON.stringify(data) + "\n\n");
  });
});

setInterval(function() {
  console.log("emitting event");
  Stream.emit("push", "message", {
    port: port,
    build: build,
    now: Date.now()
  });
}, 1000);

var liveapp = app.listen(port, function() {
  console.log("Listening on " + port);
});

process.on("SIGTERM", function() {
  gracefullyExiting = true;
  console.log("Received kill signal (SIGTERM), shutting down");
  setTimeout(function() {
    console.error(
      "Could not close connections in time, forcefully shutting down"
    );
    return process.exit(1);
  }, 10 * 1000);
  return liveapp.close(function() {
    console.info("Closed out remaining connections.");
    return process.exit();
  });
});
