require File.expand_path("helper", File.dirname(__FILE__))
require "goofy/test"

scope do
  test do
    Goofy.define do
      on root do
        res.write "home"
      end

      on "about" do
        res.write "about"
      end
    end

    get "/"
    assert_equal "home", last_response.body

    get "/about"
    assert_equal "about", last_response.body
  end
end
