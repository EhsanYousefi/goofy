class Goofy
  class Controller

    def self.construct(arg)
      self.new(arg).entry
    end

    def initialize(app)
      @app = app
    end

    def response
      res.write "<h3>You should define `response` instance method on your controller class!</h3>"
    end

    def method_missing(name, *args, &block)
      @app.send(name, *args, &block)
    end

  end
end
