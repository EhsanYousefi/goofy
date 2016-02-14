require_relative "helper"
require "goofy/safe/csrf"
require "goofy/test"

def assert_no_raise
  yield
  success
end

class UnsafeRequest < RuntimeError; end

scope do
  setup do
    Goofy.reset!

    Goofy.use(Rack::Session::Cookie, secret: "_this_must_be_secret")
    Goofy.plugin(Goofy::Safe::CSRF)
  end

  test "safe http methods" do
    Goofy.define do
      raise UnsafeRequest if csrf.unsafe?
    end

    assert_no_raise do
      get  "/"
      head "/"
    end
  end

  test "invalid csrf param" do
    Goofy.define do
      if csrf.unsafe?
        csrf.reset!
      end

      res.write(csrf.token)
    end

    get "/"

    old_token = last_response.body

    post "/", "csrf_token" => "nonsense"

    new_token = last_response.body

    assert(old_token != new_token)
  end

  test "valid csrf param" do
    Goofy.define do
      raise unless csrf.safe?

      on get do
        res.write(csrf.token)
      end

      on post do
        res.write("safe")
      end
    end

    get "/"

    csrf_token = last_response.body

    assert(!csrf_token.empty?)

    assert_no_raise do
      post "/", "csrf_token" => csrf_token
    end
  end

  test "http header" do
    csrf_token = SecureRandom.hex(32)

    Goofy.define do
      session[:csrf_token] = csrf_token
      raise if csrf.unsafe?
    end

    assert_no_raise do
      post "/", {}, { "HTTP_X_CSRF_TOKEN" => csrf_token }
    end
  end

  test "sub app raises too" do
    class App < Goofy
      define do
        on post do
          res.write("unsafe")
        end
      end
    end

    Goofy.define do
      raise UnsafeRequest unless csrf.safe?

      on "app" do
        run(App)
      end
    end

    assert_raise(UnsafeRequest) do
      post "/app"
    end
  end

  test "only sub app" do
    class App < Goofy
      define do
        raise UnsafeRequest unless csrf.safe?

        on post do
          res.write("unsafe")
        end
      end
    end

    Goofy.define do
      on "app" do
        run(App)
      end

      on default do
        res.write("safe")
      end
    end

    assert_no_raise do
      post "/"
    end

    assert_raise(UnsafeRequest) do
      post "/app"
    end
  end
end
