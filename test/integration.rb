require File.expand_path("helper", File.dirname(__FILE__))

test "resetting" do
  old = Goofy.app
  assert old.object_id == Goofy.app.object_id

  Goofy.reset!
  assert old.object_id != Goofy.app.object_id
end

class Middle
  def initialize(app, first, second, &block)
    @app, @first, @second, @block = app, first, second, block
  end

  def call(env)
    env["m.first"] = @first
    env["m.second"] = @second
    env["m.block"] = @block.call

    @app.call(env)
  end
end

test "use passes in the arguments and block" do
  Goofy.use Middle, "First", "Second" do
    "this is the block"
  end

  Goofy.define do
    on get do
      on "hello" do
        "Default"
      end
    end
  end

  env = { "REQUEST_METHOD" => "GET", "PATH_INFO" => "/hello",
          "SCRIPT_NAME" => "/" }

  Goofy.call(env)

  assert "First" == env["m.first"]
  assert "Second" == env["m.second"]
  assert "this is the block" == env["m.block"]
end

test "reset and use" do
  Goofy.use Middle, "First", "Second" do
    "this is the block"
  end

  Goofy.define do
    on get do
      on "hello" do
        res.write "Default"
      end
    end
  end

  Goofy.reset!

  Goofy.use Middle, "1", "2" do
    "3"
  end

  Goofy.define do
    on get do
      on "hello" do
        res.write "2nd Default"
      end
    end
  end

  env = { "REQUEST_METHOD" => "GET", "PATH_INFO" => "/hello",
          "SCRIPT_NAME" => "/" }

  status, headers, resp = Goofy.call(env)

  assert_equal 200, status
  assert "text/html; charset=utf-8" == headers["Content-Type"]
  assert_response resp, ["2nd Default"]

  assert "1" == env["m.first"]
  assert "2" == env["m.second"]
  assert "3" == env["m.block"]
end

test "custom response" do
  class MyResponse < Goofy::Response
    def foobar
      write "Default"
    end
  end

  Goofy.settings[:res] = MyResponse

  Goofy.define do
    on get do
      on "hello" do
        res.foobar
      end
    end
  end

  env = { "REQUEST_METHOD" => "GET", "PATH_INFO" => "/hello",
          "SCRIPT_NAME" => "/" }

  status, headers, resp = Goofy.call(env)

  assert 200 == status
  assert "text/html; charset=utf-8" == headers["Content-Type"]
  assert_response resp, ["Default"]
end
