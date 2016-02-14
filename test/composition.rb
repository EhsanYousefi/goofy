require File.expand_path("helper", File.dirname(__FILE__))

test "composing on top of a PATH" do
  Services = Goofy.new {
    on "services/:id" do |id|
      res.write "View #{id}"
    end
  }

  Goofy.define do
    on "provider" do
      run Services
    end
  end

  env = { "SCRIPT_NAME" => "/", "PATH_INFO" => "/provider/services/101" }

   _, _, resp = Goofy.call(env)

   assert_response resp, ["View 101"]
end

test "redefining not_found" do
  class Users < Goofy
    def not_found
      res.status = 404
      res.write "Not found!"
    end

    define do
      on root do
        res.write "Users"
      end
    end
  end

  class Goofy
    def not_found
      res.status = 404
      res.write "Error 404"
    end
  end

  Goofy.define do
    on "users" do
      run Users
    end
  end

  env = { "SCRIPT_NAME" => "/", "PATH_INFO" => "/users" }

  _, _, resp = Goofy.call(env)

  assert_response resp, ["Users"]

  env = { "SCRIPT_NAME" => "/", "PATH_INFO" => "/users/42" }

  status, _, resp = Goofy.call(env)

  assert_response resp, ["Not found!"]
  assert_equal status,  404

  env = { "SCRIPT_NAME" => "/", "PATH_INFO" => "/guests" }

  status, _, resp = Goofy.call(env)

  assert_response resp, ["Error 404"]
  assert_equal status,  404
end
