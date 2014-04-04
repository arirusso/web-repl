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

module WebRepl

  VERSION = "0.2"

  # Shortcut to REPL.start
  def self.start(*a)
    REPL.start(*a)
  end

end
