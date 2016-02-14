require File.expand_path("helper", File.dirname(__FILE__))

test "set cookie" do
  Goofy.define do
    on default do
      res.set_cookie("foo", "bar")
      res.set_cookie("bar", "baz")
      res.write "Hello"
    end
  end

  env = { "SCRIPT_NAME" => "/", "PATH_INFO" => "/" }

   _, headers, body = Goofy.call(env)

   assert_equal "foo=bar\nbar=baz", headers["Set-Cookie"]
end

test "delete cookie" do
  Goofy.define do
    on default do
      res.set_cookie("foo", "bar")
      res.delete_cookie("foo")
      res.write "Hello"
    end
  end

  env = { "SCRIPT_NAME" => "/", "PATH_INFO" => "/" }

   _, headers, body = Goofy.call(env)

   assert_equal "foo=; max-age=0; expires=Thu, 01 Jan 1970 00:00:00 -0000",
     headers["Set-Cookie"]
end
