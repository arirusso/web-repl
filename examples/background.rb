#!/usr/bin/env ruby
$:.unshift(File.join("..", "lib"))

require "web-repl"

repl = WebRepl::REPL.new(:host => "localhost", :port => 9007)

repl.start(:background => true) do
  repl.evaluate("2 + 2;")
  repl.evaluate("alert('hi');")
end

repl.wait_for_response
repl.close
exit 0
