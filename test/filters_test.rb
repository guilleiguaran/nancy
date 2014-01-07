require File.expand_path('../test_helper', __FILE__)

class FiltersTest < Minitest::Test
  include Rack::Test::Methods

  class TestApp < Nancy::Base
    before do
      halt 401, "unauthorized" if request.path_info == "/protected"
    end

    after do
      response["Content-Type"] = "application/json"
    end

    get "/" do
      %q({"message":"hello world"})
    end

    get "/protected" do
      "This is protected!!"
    end
  end

  def app
    TestApp.new
  end

  def test_before_filter
    get '/protected'
    assert_equal 401, last_response.status
    assert_equal "unauthorized", last_response.body
  end

  def test_after_filter
    get '/'
    assert_equal 'application/json', last_response.headers['Content-Type']
    assert_equal %q({"message":"hello world"}), last_response.body
  end
end
