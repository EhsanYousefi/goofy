class Goofy
  class Controller

    def self.construct(arg,paramters)
      self.new(arg,paramters).entry
    end
    
    attr_reader :params
    
    def initialize(app,params)
      @app = app
      @params = params
    end

    def response
      res.write "<h3>You should define `response` instance method on your controller class!</h3>"
    end

    def method_missing(name, *args, &block)
      @app.send(name, *args, &block)
    end

  end
end
