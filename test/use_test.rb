require File.expand_path('../test_helper', __FILE__)

class Reverser
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)
    body = response.body
    [status, headers, [body.first.reverse]]
  end
end

class HelloApp < Nancy::Base
  use Reverser

  get "/" do
    "Hello World"
  end
end

class UseTest < MiniTest::Unit::TestCase

  def test_use
    request = Rack::MockRequest.new(HelloApp)
    response = request.get('/')
    assert_equal "dlroW olleH", response.body
  end
end
