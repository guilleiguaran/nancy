require File.expand_path('../test_helper', __FILE__)

class BaseTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  class AdminApp < Nancy::Base
    use Rack::Session::Cookie

    get "/login" do
      session['user_id'] = 1
    end

    get "/logout" do
      session['user_id'] = nil
    end

    get "/protected", :signed_in? do
      "Protected area"
    end

    get "/unauthorized" do
      "Unauthorized!!!"
    end

    def signed_in?
      return true if session['user_id']
      redirect "/unauthorized"
    end
  end

  def app
    AdminApp
  end

  def test_filter
    get '/login'
    get '/protected'
    assert_equal "Protected area", last_response.body
    get '/logout'
  end

  def test_filter_pass
    get '/logout'
    get '/protected'
    follow_redirect!
    assert_equal "Unauthorized!!!", last_response.body
  end
end
