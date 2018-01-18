require File.expand_path('../test_helper', __FILE__)

class FiltersTest < Minitest::Test
  include Rack::Test::Methods

  class TestApp < Nancy::Base
    before("/protected") do
      halt 401, "unauthorized"
    end

    before("/object/:id") do |params|
      @object = params["id"]
    end

    before("/splat/:root/*.*") do |params|
      @root = params["root"]
      @path = params["splat"][0]
      @ext  = params["splat"][1]
    end

    before do
      response.write "1 "
    end

    before do
      response.write "2 "
    end

    after do
      response.write " 3"
    end

    after do
      response.write " 4"
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

    get "/object/*" do
      "Looking at #{@object}"
    end

    get "/splat/*" do
      "root #{@root} path #{@path} ext #{@ext}"
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
    assert_equal %q(1 2 {"message":"hello world"} 4 3), last_response.body
  end

  def test_before_filter_params
    get '/object/49'
    assert_equal "1 2 Looking at 49 4 3", last_response.body
  end

  def test_before_filter_params_multiple_arguments
    get '/splat/foo/file.png'
    assert_equal "1 2 root foo path file ext png 4 3", last_response.body
  end
end
