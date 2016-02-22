class Goofy
  module Router

    def controller(ctrl_class, params={})
      ctrl_class.construct self, params
    end

  end
end
