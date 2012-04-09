# Nancy
_Sinatra's little daughter_

![Frank and Nancy by classic film scans](http://farm6.staticflickr.com/5212/5386187897_e3155cec68.jpg)


## Description

Minimal Ruby microframework for web development inspired in [Sinatra](http://www.sinatrarb.com/) and [Cuba](https://github.com/soveran/cuba)


## Installation

Install the gem:

    $ gem install nancy

or add it to your Gemfile:

    gem "nancy"


## Usage

Here's a simple application:

```ruby
# hello.rb
require "nancy"

class Hello < Nancy::Base
  use Rack::Session::Cookie # for sessions
  include Nancy::Render # for templates

  get "/" do
    "Hello World"
  end

  get "/hello" do
    redirect "/"
  end

  get "/hello/:name" do
    "Hello #{params['name']}"
  end

  post "/hello" do
    "Hello #{params['name']}"
  end

  get "/template" do
    @message = "Hello world"
    render("views/hello.erb")
  end

  post "/login" do
    @user = User.find(params['username'])
    halt 401, "unauthorized" unless @user.authenticate(params['password'])
    session[:authenticated] = true
    render("views/layout.erb") { render("views/welcome.erb") }
  end

  get "/users/:id.json" do
    @user = User.find(params['id'])
    response["Content-Type"] = "application/json"
    halt 404 unless @user
    UserSerializer.new(@user).to_json
  end

  map "/resque" do
    run Resque::Server
  end

  map "/nancy" do
    run AnotherNancyApp
  end
end
```

To run it, you can create a `config.ru` file:

```ruby
# config.ru
require "./hello"

run Hello
```

You can now run `rackup` and enjoy what you have just created.

Check examples folder for a detailed example.


## Features

*  "Sinatra-like" routes: support for get, post, put, patch, delete, options, head
*  Template rendering and caching through Tilt
*  Include middlewares with the use method
*  Mount rack apps with the map method
*  Sessions through Rack::Session
*  Halt execution at any point using Ruby's throw/catch mechanism
*  Thread-safe


## Version history

### 0.2.0 (Unreleased)

*   Set PATH INFO to '/' when is blank
*   Fixed session method: Raise error when is used but Rack::Session isn't present
*   Added support for HEAD and OPTIONS HTTP verbs
*   Refactored Base.use to use a Rack::Builder internally
*   Added Base.map to redirect requests to Rack sub-apps

### 0.1.0 (April 4, 2012)

*   Created a new [Github Page](http://guilleiguaran.github.com/nancy) for the project
*   Added env accessor, this add support for [Shield](https://github.com/cyx/shield)
*   Added support for templates caching using Tilt::Cache
*   Moved render method from Nancy::Base to Nancy::Render module
*   Refactored Nancy::Base to evaluate code blocks at instance level
*   Fixed passing of render options to Tilt (thanks to [lporras](https://github.com/lporras))

### 0.0.1 (March 20, 2012)

*   Initial Release


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## Copyright

Copyright (c) 2012 Guillermo Iguaran. See LICENSE for
further details.
