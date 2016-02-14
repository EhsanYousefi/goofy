require "goofy"
require "cutest"
require "rack/test"

class Cutest::Scope
  include Rack::Test::Methods

  def app
    Goofy
  end
end
