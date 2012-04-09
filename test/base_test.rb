require File.expand_path('../test_helper', __FILE__)

class BaseTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  class TestApp < Nancy::Base
    use Rack::Session::Cookie

    get "/" do
      "Hello World"
    end

    get "/hello/:name" do
      "Hello #{params['name']}"
    end

    post "/hello" do
      "Hello #{params['name']}"
    end

    get "/hello" do
      "Hello #{params['name']}"
    end

    get "/redirect" do
      redirect "/destination"
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
    TestApp
  end

  def test_app_respond_with_call
    assert TestApp.new.respond_to?(:call)
    request = Rack::MockRequest.new(TestApp)
    response = request.get('/')
    assert_equal 200, response.status
    assert_equal 'Hello World', response.body
  end

  def test_url_params
    get '/hello/user'
    assert_equal 'Hello user', last_response.body
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
    assert 500, last_response.status
    assert_equal 'Internal Error', last_response.body
  end

  def test_session
    get '/session'
    assert_equal "session['test'] content is: test", last_response.body
  end
end
