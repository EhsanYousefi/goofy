require_relative "helper"

require "goofy/render"

test "doesn't override the settings if they already exist" do
  Goofy.settings[:render] = {
    :views => "./test/views",
    :template_engine => "haml"
  }

  Goofy.plugin Goofy::Render

  assert_equal "./test/views", Goofy.settings[:render][:views]
  assert_equal "haml", Goofy.settings[:render][:template_engine]
end

scope do
  setup do
    Goofy.plugin Goofy::Render
    Goofy.settings[:render][:views] = "./test/views"
    Goofy.settings[:render][:template_engine] = "erb"

    Goofy.define do
      on "home" do
        res.write view("home", name: "Agent Smith", title: "Home")
      end

      on "about" do
        res.write partial("about", title: "About Goofy")
      end

      on "render" do
        render("about", title: "About Goofy")
      end
    end
  end

  test "partial" do
    _, _, body = Goofy.call({ "PATH_INFO" => "/about", "SCRIPT_NAME" => "/" })

    assert_response body, ["<h1>About Goofy</h1>"]
  end

  test "view" do
    _, _, body = Goofy.call({ "PATH_INFO" => "/home", "SCRIPT_NAME" => "/" })

    assert_response body, ["<title>Goofy: Home</title>\n<h1>Home</h1>\n<p>Hello Agent Smith</p>"]
  end

  test "render" do
    _, _, body = Goofy.call({ "PATH_INFO" => "/render", "SCRIPT_NAME" => "/" })

    assert_response body, ["<title>Goofy: About Goofy</title>\n<h1>About Goofy</h1>"]
  end

  test "partial with str as engine" do
    Goofy.settings[:render][:template_engine] = "str"

    _, _, body = Goofy.call({ "PATH_INFO" => "/about", "SCRIPT_NAME" => "/" })

    assert_response body, ["<h1>About Goofy</h1>"]
  end

  test "view with str as engine" do
    Goofy.settings[:render][:template_engine] = "str"

    _, _, body = Goofy.call({ "PATH_INFO" => "/home", "SCRIPT_NAME" => "/" })

    assert_response body, ["<title>Goofy: Home</title>\n<h1>Home</h1>\n<p>Hello Agent Smith</p>"]
  end

  test "custom default layout support" do
    Goofy.settings[:render][:layout] = "layout-alternative"

    _, _, body = Goofy.call({ "PATH_INFO" => "/home", "SCRIPT_NAME" => "/" })

    assert_response body, ["<title>Alternative Layout: Home</title>\n<h1>Home</h1>\n<p>Hello Agent Smith</p>"]
  end
end

test "caching behavior" do
  Thread.current[:_cache] = nil

  Goofy.plugin Goofy::Render
  Goofy.settings[:render][:views] = "./test/views"

  Goofy.define do
    on "foo/:i" do |i|
      res.write partial("test", title: i)
    end
  end

  10.times do |i|
    _, _, resp = Goofy.call({ "PATH_INFO" => "/foo/#{i}", "SCRIPT_NAME" => "" })
  end

  assert_equal 1, Thread.current[:_cache].instance_variable_get(:@cache).size
end

test "overrides layout" do
  Goofy.plugin Goofy::Render
  Goofy.settings[:render][:views] = "./test/views"

  Goofy.define do
    on true do
      res.write view("home", { name: "Agent Smith", title: "Home" }, "layout-alternative")
    end
  end

  _, _, body = Goofy.call({})

  assert_response body, ["<title>Alternative Layout: Home</title>\n<h1>Home</h1>\n<p>Hello Agent Smith</p>"]
end

test "ensures content-type header is set" do
  Goofy.plugin(Goofy::Render)

  Goofy.define do
    on default do
      res.status = 403
      render("about", title: "Hello Goofy")
    end
  end

  _, headers, _ = Goofy.call({})

  assert_equal("text/html; charset=utf-8", headers["Content-Type"])
end
