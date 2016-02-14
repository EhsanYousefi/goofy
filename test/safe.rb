require_relative "helper"
require "goofy/safe"

scope do
  test "secure headers" do
    Goofy.plugin(Goofy::Safe)

    class Hello < Goofy
      define do
        on root do
          res.write("hello")
        end
      end
    end

    Goofy.define do
      on root do
        res.write("home")
      end

      on "hello" do
        run(Hello)
      end
    end

    secure_headers = Goofy::Safe::SecureHeaders::HEADERS

    _, headers, _ = Goofy.call("PATH_INFO" => "/", "SCRIPT_NAME" => "/")
    secure_headers.each do |header, value|
      assert_equal(value, headers[header])
    end

    _, headers, _ = Goofy.call("PATH_INFO" => "/hello", "SCRIPT_NAME" => "/")
    secure_headers.each do |header, value|
      assert_equal(value, headers[header])
    end
  end

  test "secure headers only in sub app" do
    Goofy.settings[:default_headers] = {}

    class About < Goofy
      plugin(Goofy::Safe)

      define do
        on root do
          res.write("about")
        end
      end
    end

    Goofy.define do
      on root do
        res.write("home")
      end

      on "about" do
        run(About)
      end
    end

    secure_headers = Goofy::Safe::SecureHeaders::HEADERS

    _, headers, _ = Goofy.call("PATH_INFO" => "/", "SCRIPT_NAME" => "/")
    secure_headers.each do |header, _|
      assert(!headers.key?(header))
    end

    _, headers, _ = Goofy.call("PATH_INFO" => "/about", "SCRIPT_NAME" => "/")
    secure_headers.each do |header, value|
      assert_equal(value, headers[header])
    end
  end
end
