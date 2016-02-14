require File.expand_path("helper", File.dirname(__FILE__))

test "redirect" do
  Goofy.define do
    on "hello" do
      res.write "hello, world"
    end

    on "" do
      res.redirect "/hello"
    end
  end

  env = { "SCRIPT_NAME" => "/", "PATH_INFO" => "/" }

  status, headers, body = Goofy.call(env)

  assert_equal status, 302
  assert_equal headers, { "Location" => "/hello" }
  assert_response body, []
end
