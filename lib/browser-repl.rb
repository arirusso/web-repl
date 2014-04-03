# libs
require "colorize"
require "em-websocket"
require "json"
require "readline"
require "socket"

# classes
require "browser-repl/messager"
require "browser-repl/patch"
require "browser-repl/repl"

module BrowserRepl

  VERSION = "0.1"

  # Shortcut to REPL.start
  def self.start(*a)
    REPL.start(*a)
  end

end
