require File.expand_path("helper", File.dirname(__FILE__))

test "settings contains request and response classes by default" do
  assert_equal Goofy.settings[:req], Rack::Request
  assert_equal Goofy.settings[:res], Goofy::Response
end

test "is inheritable and allows overriding" do
  Goofy.settings[:foo] = "bar"

  class Admin < Goofy; end

  assert_equal "bar", Admin.settings[:foo]

  Admin.settings[:foo] = "baz"

  assert_equal "bar", Goofy.settings[:foo]
  assert_equal "baz", Admin.settings[:foo]
end

test do
  Goofy.settings[:hello] = "Hello World"

  Goofy.define do
    on default do
      res.write settings[:hello]
    end
  end

  _, _, resp = Goofy.call({ "PATH_INFO" => "/", "SCRIPT_NAME" => ""})

  body = []

  resp.each do |line|
    body << line
  end

  assert_equal ["Hello World"], body
end

# The following tests the settings clone bug where
# we share the same reference. Deep cloning is the solution here.
Goofy.settings[:mote] ||= {}
Goofy.settings[:mote][:layout] ||= "layout"

class Login < Goofy
  settings[:mote][:layout] = "layout/guest"
end

test do
  assert Login.settings[:mote].object_id != Goofy.settings[:mote].object_id
end
