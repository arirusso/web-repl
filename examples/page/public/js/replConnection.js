// A connection to the REPL server using Websocket
function ReplConnection(host, port, options) {
  if (options === null) {
    options = {};
  }
  this.debug = !!options.debug;
  this.reconnect = !!options.reconnect;
  this.retryTime = options.retryTime || 1000;
  this.onReceive = options.onReceive;
  this.host = host;
  this.port = port;
  this.active = false;
  this.socket;
  this.supported = ("WebSocket" in window);
  if (this.supported) {
    console.log("REPL: socket ok");
  } else {
    console.log("REPL: socket not supported");
  }
}

// This is the "eval" for the REPL
ReplConnection.prototype.eval = function(statement) {
  response = {}
  try {
    response.value = eval(statement);
  } catch(err) {
    response.error = err.message;
  }
  return response;
}

// Initialize the Websocket connection
ReplConnection.prototype.initSocket = function(successCallback) {
  if (this.socket !== undefined && this.socket !== null) { 
    this.socket.close();
  }
  var address = "ws://" + this.host + ":" + this.port + "/echo";
  this.socket = new WebSocket(address);
  successCallback();
}

// To be run when the Websocket registers as being open
ReplConnection.prototype.handleSocketOpen = function() {
  this.active = true;
  console.log("REPL: socket ready");
}

// Try to create a Websocket connection
ReplConnection.prototype.tryConnection = function() {
  console.log("REPL: waiting for connection");
  if (this.reconnect) {
    var connection = this;
    window.setTimeout(function() {
      connection.start();
    }, this.retryTime);
  }
}

// To be run when the Websocket registers as being closed.  This includes when it's waiting for a connection.
ReplConnection.prototype.handleSocketClose = function(event) {
  if (!this.active) {
    this.tryConnection();  
  } else {  
    console.log("REPL: socket closed"); 
    this.active = false;
    if (this.reconnect) {
      this.tryConnection();
    }
  }
}

// To be run when the Websocket registers an event over the connection.
ReplConnection.prototype.handleMessageReceived = function(event) {
  if (this.debug) {
    console.log("REPL: message received");
    console.log(event);
  }
  var message = JSON.parse(event.data);
  // turn the timestamp from the rec'd message into a real date
  var timestamp = message.timestamp;
  message.timestamp = new Date(timestamp); 
  //
  if (this.onReceive !== undefined) {
    this.onReceive(message); // fire the custom callback
  }
  // prepare the response
  var response = this.eval(message.statement); // evaluate the statement
  response.timestamp = new Date().getTime(); // timestamp for the returned message
  var json = JSON.stringify(response);
  if (this.debug) {
    console.log("REPL: replying ");
    console.log(response);
  }
  this.socket.send(json);
}

// Initialize the Websocket event handling actions
ReplConnection.prototype.initEventHandling = function() {
  var connection = this;
  this.socket.onopen = function() { connection.handleSocketOpen() };
  this.socket.onclose = function(event) { connection.handleSocketClose(event); };
  this.socket.onmessage = function(event) { connection.handleMessageReceived(event); };
}

// Initialize the Websocket and start waiting for a REPL connection
ReplConnection.prototype.start = function(successCallback) {
  if (this.supported) {
    var connection = this;
    this.initSocket(function() {
      connection.initEventHandling();
      if (successCallback !== undefined) {
        successCallback(connection);
      }
    });
  }
}
