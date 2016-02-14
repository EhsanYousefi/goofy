require "goofy"
require "cutest"
require "capybara/dsl"

class Cutest::Scope
  if defined? Capybara::DSL
    include Capybara::DSL
  else
    include Capybara
  end
end

Capybara.app = Goofy
