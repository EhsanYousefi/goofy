require File.expand_path("helper", File.dirname(__FILE__))

setup do
  { "SCRIPT_NAME" => "/", "PATH_INFO" => "/about/1/2" }
end

test "paths and numbers" do |env|
  Goofy.define do
    on "about" do
      on :one, :two do |one, two|
        res.write one
        res.write two
      end
    end
  end

  _, _, resp = Goofy.call(env)

  assert_response resp, ["1", "2"]
end

test "paths and decimals" do |env|
  Goofy.define do
    on "about" do
      on(/(\d+)/) do |one|
        res.write one
      end
    end
  end

  env["PATH_INFO"] = "/about/1.2"

  _, _, resp = Goofy.call(env)

  assert_response resp, []
end
