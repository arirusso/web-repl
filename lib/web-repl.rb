# libs
require "colorize"
require "em-websocket"
require "json"
require "readline"
require "socket"

# classes
require "web-repl/messager"
require "web-repl/patch"
require "web-repl/repl"

# A Javascript REPL that runs in Ruby. Evaluation is done by a web browser instance.
module WebRepl

  VERSION = "0.6"

  # Shortcut to REPL.start
  def self.start(*a)
    REPL.start(*a)
  end

end
