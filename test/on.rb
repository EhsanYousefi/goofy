require File.expand_path("helper", File.dirname(__FILE__))

test "executes on true" do
  Goofy.define do
    on true do
      res.write "+1"
    end
  end

  _, _, resp = Goofy.call({})

  assert_response resp, ["+1"]
end

test "executes on non-false" do
  Goofy.define do
    on "123" do
      res.write "+1"
    end
  end

  _, _, resp = Goofy.call({ "PATH_INFO" => "/123", "SCRIPT_NAME" => "/" })

  assert_response resp, ["+1"]
end

test "ensures SCRIPT_NAME and PATH_INFO are reverted" do
  Goofy.define do
    on lambda { env["SCRIPT_NAME"] = "/hello"; false } do
      res.write "Unreachable"
    end
  end

  env = { "SCRIPT_NAME" => "/", "PATH_INFO" => "/hello" }

  _, _, resp = Goofy.call(env)

  assert_equal "/", env["SCRIPT_NAME"]
  assert_equal "/hello", env["PATH_INFO"]
  assert_response resp, []
end

test "skips consecutive matches" do
  Goofy.define do
    on true do
      env["foo"] = "foo"

      res.write "foo"
    end

    on true do
      env["bar"] = "bar"

      res.write "bar"
    end
  end

  env = {}

  _, _, resp = Goofy.call(env)

  assert_equal "foo", env["foo"]
  assert_response resp, ["foo"]

  assert ! env["bar"]
end

test "finds first match available" do
  Goofy.define do
    on false do
      res.write "foo"
    end

    on true do
      res.write "bar"
    end
  end

  _, _, resp = Goofy.call({})

  assert_response resp, ["bar"]
end

test "reverts a half-met matcher" do
  Goofy.define do
    on "post", false do
      res.write "Should be unmet"
    end
  end

  env = { "PATH_INFO" => "/post", "SCRIPT_NAME" => "/" }
  _, _, resp = Goofy.call(env)

  assert_response resp, []
  assert_equal "/post", env["PATH_INFO"]
  assert_equal "/", env["SCRIPT_NAME"]
end

test "responds 404 if conditions are not met" do
  Goofy.define do
    on root do
      res.write("Should be unmet")
    end
  end

  env = { "PATH_INFO" => "/notexists", "SCRIPT_NAME" => "/" }
  status, _, body = Goofy.call(env)

  assert_equal 404, status
  assert body.empty?
end

test "responds 404 if nested conditions are not met" do
  Goofy.define do
    on get do
      on root do
        res.write("Should be unmet")
      end
    end

    on default do
      res.write("Should be unmet")
    end
  end

  env = {
    "REQUEST_METHOD" => "GET",
    "PATH_INFO" => "/notexists",
    "SCRIPT_NAME" => "/"
  }

  status, _, body = Goofy.call(env)

  assert_equal 404, status
  assert body.empty?
end

test "responds 200 even with an empty body if status is set" do
  Goofy.define do
    on get do
      on root do
        res.status = 200
      end
    end
  end

  env = {
    "REQUEST_METHOD" => "GET",
    "PATH_INFO" => "/",
    "SCRIPT_NAME" => "/"
  }

  status, _, body = Goofy.call(env)

  assert_equal 200, status
  assert body.empty?
end
