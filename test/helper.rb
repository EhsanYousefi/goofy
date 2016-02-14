$:.unshift(File.expand_path("../lib", File.dirname(__FILE__)))
require "goofy"

prepare { Goofy.reset! }

def assert_response(body, expected)
  arr = body.map { |line| line.strip }

  flunk "#{arr.inspect} != #{expected.inspect}" unless arr == expected
  print "."
end
