require_relative "helper"

require "goofy/controller"

scope do
  setup do
    @@___stack_ = []
    class HomeControlelr < Goofy::Controller
      before_response -> { @message = "before_response_from_controller"; @@___stack_ << @message }
      around_response -> { @around = "around_from_controller"; @@___stack_ << @around }
      after_response -> { @after = "after_from_controller"; @@___stack_ << @after }
      def response
        res.write(@message)
      end
    end
    Goofy.define do
      on "home" do
        controller HomeControlelr
      end
    end
  end

  test "response" do
    _, _, body = Goofy.call({ "PATH_INFO" => "/home", "SCRIPT_NAME" => "/" })

    assert_response body, ["before_response_from_controller"]
    assert_equal ["before_response_from_controller", "around_from_controller", "around_from_controller", "after_from_controller"], @@___stack_
  end
end
