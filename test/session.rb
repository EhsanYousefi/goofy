require_relative "helper"

test do
  Goofy.define do
    on default do
      begin
        session
      rescue Exception => e
        res.write e.message
      end
    end
  end

  _, _, body = Goofy.call({})

  body.each do |e|
    assert e =~ /Goofy.use Rack::Session::Cookie/
  end
end


