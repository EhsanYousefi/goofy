require_relative "helper"

scope do
  module Helper
    def clean(str)
      str.strip
    end
  end

  test do
    Goofy.plugin Helper

    Goofy.define do
      on default do
        res.write clean " foo "
      end
    end

    _, _, body = Goofy.call({})

    assert_response body, ["foo"]
  end
end

scope do
  module Number
    def num
      1
    end
  end

  module Plugin
    def self.setup(app)
      app.plugin Number
    end

    def bar
      "baz"
    end

    module ClassMethods
      def foo
        "bar"
      end
    end
  end

  setup do
    Goofy.plugin Plugin

    Goofy.define do
      on default do
        res.write bar
        res.write num
      end
    end
  end

  test do
    assert_equal "bar", Goofy.foo
  end

  test do
    _, _, body = Goofy.call({})

    assert_response body, ["baz", "1"]
  end
end
