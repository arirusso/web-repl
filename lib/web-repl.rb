# libs
require "colorize"
require "em-websocket"
require "json"
require "readline" unless defined?(Readline)
require "socket"

# classes
require "web-repl/messenger"
require "web-repl/patch"
require "web-repl/repl"

# A Javascript REPL that runs in Ruby. Evaluation is done by a web browser instance.
module WebRepl

  VERSION = "0.10.1"

  # Shortcut to REPL.start
  def self.start(*a)
    REPL.start(*a)
  end

end
