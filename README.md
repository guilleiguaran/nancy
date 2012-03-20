# Nancy

"Sinatra's little daughter"

Minimal microframework for web development inspired in Sinatra

## Installation

Install the gem:

    $ gem install fakeredis

or add it to your Gemfile:

    gem "fakeredis"

## Usage

Here's a simple application:

```ruby
# hello.rb
require "nancy"

class Hello < Nancy::Base
  use Rack::Session::Cookie

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
end
```

To run it, you can create a `config.ru` file:

``` ruby
# config.ru
require "./hello"

run App.new
```

You can now run `rackup` and enjoy what you have just created.

Check examples folder for an detailed example.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
