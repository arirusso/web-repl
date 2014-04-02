dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift dir + '/../lib'

require 'test/unit'
require "mocha/test_unit"
require "shoulda-context"

require "browser-repl"
