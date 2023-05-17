require File.expand_path('../test_helper', __FILE__)

class BaseTest < Minitest::Test
  include Rack::Test::Methods

  class TestApp < Nancy::Base
    use Rack::Session::Cookie, secret: "secret"

    get "/" do
      "Hello World"
    end

    get "/hello/:name" do
      "Hello #{params['name']}"
    end

    get "/splat/*string" do
      "Splat #{params['string']}"
    end

    get "/optional(/:id)?" do
      "Optional #{params['id'] || 'not provided'}"
    end

    post "/hello" do
      "Hello #{params['name']}"
    end

    get "/hello" do
      "Hello #{params['name']}"
    end

    get "/redirect" do
      response.redirect "/destination"
    end

    get "/destination" do
      "Redirected from /redirect"
    end

    get "/halting" do
      halt 500, "Internal Error"
      "not reached code"
    end

    get "/session" do
      session['test'] = "test"
      "session['test'] content is: #{session['test']}"
    end
  end

  def app
    TestApp.new
  end

  def test_app_respond_with_call
    assert TestApp.new.respond_to?(:call)
    request = Rack::MockRequest.new(TestApp.new)
    response = request.get('/')
    assert_equal 200, response.status
    assert_equal 'Hello World', response.body
  end

  def test_url_params
    get '/hello/user'
    assert_equal 'Hello user', last_response.body
  end

  def test_splat_params
    get '/splat/foo/bar/baz'
    assert_equal 'Splat foo/bar/baz', last_response.body
  end

  def test_optional_params
    get '/optional'
    assert_equal 'Optional not provided', last_response.body

    get '/optional/4'
    assert_equal 'Optional 4', last_response.body

    get '/optional/'
    assert_equal 404, last_response.status
  end

  def test_post_params
    post '/hello', :name => 'bob'
    assert_equal 'Hello bob', last_response.body
  end

  def test_query_params
    get '/hello?name=foo'
    assert_equal 'Hello foo', last_response.body
  end

  def test_redirect
    get '/redirect'
    follow_redirect!
    assert last_response.body.include?('Redirected')
  end

  def test_halting
    get '/halting'
    assert_equal 500, last_response.status
    assert_equal 'Internal Error', last_response.body
  end

  def test_session
    get '/session'
    assert_equal "session['test'] content is: test", last_response.body
  end
end
