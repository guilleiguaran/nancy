require File.expand_path("../test_helper", __FILE__)

class Reverser
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)
    [status, headers, [body.first.reverse]]
  end
end

class HelloApp < Nancy::Base
  use Reverser

  get "/" do
    "Hello World"
  end
end

class UseTest < Minitest::Test
  def test_use
    request  = Rack::MockRequest.new(HelloApp.new)
    response = request.get("/")

    assert_equal "dlroW olleH", response.body
  end
end
