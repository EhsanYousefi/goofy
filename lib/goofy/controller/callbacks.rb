require 'prong'

class Goofy
  class Controller

    include Prong

    # Define before, around, after callbacks for #response
    define_hook :response

    def entry
      run_hooks :response do
        # Call response method with running callbacks
        response
      end
    end

  end
end
