module.exports = function(app, build, port) {
  var EventEmitter = require("events");
  var Stream = new EventEmitter();

  app.get("/sse", function(req, res) {
    res.sendFile(__dirname + "/server-sent-event-page.html");
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
};
