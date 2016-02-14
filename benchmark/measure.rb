require "benchmark"
require "../lib/goofy"
require "../lib/goofy/controller"

class HomeController < Goofy::Controller

  def response
    res.write("wazzup?")
  end

end

Goofy.define do
  on "c" do
    controller HomeController
  end
  on "w" do
    res.write("wazzup?")
  end
end

Benchmark.bmbm do |x|

  x.report "with controller" do
    10000.times do
      Goofy.call({ "PATH_INFO" => "/c", "SCRIPT_NAME" => "/" })
    end
  end

  x.report "without controller" do
    10000.times do
      Goofy.call({ "PATH_INFO" => "/w", "SCRIPT_NAME" => "/" })
    end
  end
end
