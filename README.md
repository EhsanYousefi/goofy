# Goofy

A microframework for web development heavily based on [cuba.is][cuba]

![Goofy](http://www.coloring-book.info/coloring/Goofy/goofy_12.jpg)

## Description

Goofy is a microframework for web heavily based on [cuba.is][cuba].
[cuba.is][cuba] is the fastest ruby microframework at the moment.
Goofy is fast as [cuba.is][cuba] but more featured and structured.

## Installation

    $ gem install goofy

## Usage

Run:

    $ goofy help

To get nessecary information.

## Controllers

Goofy controllers follow SRP(Single Responsibility Principle), in other words each action maps to one controller.
Goofy controllers use [https://github.com/EhsanYousefi/Prong][Prong] in order to support rails-like callbacks.
Every method that available in Cuba router is available in Goofy controller like `res.write`.
Create new Goofy application and generate a controller to get to know Goofy controllers.

Services
--------
In order to understand Goofy services, take a look at [https://github.com/krisleech/wisper][wisper] documentation, in other words Goofy uses [https://github.com/krisleech/wisper][wisper] to decouple core business logic from external concerns in Hexagonal style architectures.

## Router

There is no difference between Goofy router and Cuba router expect controller method:
```ruby
# app/controlers/welcome_controller.rb
class WelcomeController < ApplicationController
  def response
    res.write "Foo Bar"
  end
end
```
```ruby
# config/router.rb
Goofy.define do
  on get, "welcome" do
    controller WelcomeController
  end
end
```

## Test

Goofy uses [https://github.com/rspec/rspec][Rspec] as default test system.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/EhsanYousefi/closet. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
