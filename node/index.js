var express = require("express");
var app = new express();
var TIMEOUT = 10 * 1000; // 10s
var port = process.env.APP_PORT;
var build = Date.now();

app.get("/", function(req, res) {
  res.send(port + " " + build + " " + Date.now());
});

require("./server-sent-event-middleware")(app, build, port);

app.listen(port, function() {
  console.log("Listening on " + port);
});

// Calling server.close allows us to refuse new requests while
// continuing to server existing requests. We could just let
// the process die but this might mean half-finished requests.
process.on("SIGTERM", function() {
  console.log("Received kill signal (SIGTERM), shutting down");

  setTimeout(function() {
    console.error(
      "Could not close connections in time, forcefully shutting down"
    );
    process.exit(1);
  }, TIMEOUT);

  app.close(function() {
    console.info("Closed out remaining connections.");
    process.exit();
  });
});
