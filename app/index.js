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

require('./server-sent-event-middleware')(app, build, port);

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
