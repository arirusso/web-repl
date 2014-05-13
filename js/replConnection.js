// A connection to the REPL server using Websocket
function ReplConnection(host, port, options) {
  options = (typeof options === "undefined") ? {} : options;
  this.debug = !!options.debug;
  this.reconnect = !!options.reconnect;
  this.retryTime = options.retryTime || 1000;
  this.evalFunction = options.evalFunction;
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
// statement: the statement to evaluate
ReplConnection.prototype.eval = function(statement) {
  options = (typeof options === "undefined") ? {} : options;
  var response = {};
  try {
    if (typeof this.evalFunction === "function") {
      response.value = this.evalFunction(statement);
    } else {
      response.value = eval(statement);
    }
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

// turn the timestamp from the rec'd message into a real date
ReplConnection.prototype.convertTimestamp = function(message) {
  var timestamp = message.timestamp;
  message.timestamp = new Date(timestamp); 
  return message.timestamp;
}

// To be run when the Websocket registers an event over the connection.
ReplConnection.prototype.handleMessageReceived = function(event) {
  if (this.debug) {
    console.log("REPL: message received");
    console.log(event);
  }
  var message = JSON.parse(event.data);
  this.convertTimestamp(message);
  var response = this.eval(message.statement); // evaluate the statement
  return this.send(response);
}

// Send a message
ReplConnection.prototype.send = function(message) {
  var json = this.prepareJSON(message);
  if (this.debug) {
    console.log("REPL: sending");
    console.log(json);
  }
  return this.socket.send(json);
}

// Convert a message to JSON for sending
ReplConnection.prototype.prepareJSON = function(message) {
  // prepare the response
  var json;
  try {
    message.timestamp = new Date().getTime(); // timestamp for the returned message
    json = JSON.stringify(message);
  } catch(error) {
    json = this.handleJsonError(message, error);  
  }
  return json;
}

// Handle an error when converting the message to JSON
ReplConnection.prototype.handleJsonError = function(message, error) {
  message.value = null;
  message.error = error.message;
  return this.prepareJSONResponse(message);
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
