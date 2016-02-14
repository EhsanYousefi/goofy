require_relative "safe/csrf"
require_relative "safe/secure_headers"

class Goofy
  # == Goofy::Safe
  #
  # This plugin contains security related features for Goofy
  # applications. It takes ideas from secureheaders[1].
  #
  # == Usage
  #
  #     require "goofy"
  #     require "goofy/safe"
  #
  #     Goofy.plugin(Goofy::Safe)
  #
  module Safe
    def self.setup(app)
      app.plugin(Safe::SecureHeaders)
      app.plugin(Safe::CSRF)
    end
  end
end
