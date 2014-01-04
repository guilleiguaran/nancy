require File.expand_path('../test_helper', __FILE__)
require 'nancy/render'

class BaseTest < Minitest::Test
  include Rack::Test::Methods

  class TestApp < Nancy::Base
    include Nancy::Render

    get "/view" do
      @message = "Hello from view"
      render("#{view_path}/view.erb")
    end

    get "/layout" do
      @message = "Hello from view"
      render("#{view_path}/layout.erb") { render("#{view_path}/view.erb") }
    end

    get "/view_with_option_trim" do
      render("#{view_path}/view_with_trim.erb", {}, :trim => true)
    end

    def view_path
      File.expand_path("fixtures", Dir.pwd)
    end
  end

  def app
    TestApp
  end

  def test_render
    get '/view'
    assert !last_response.body.include?("<html>")
    assert last_response.body.include?("Hello from view")
  end

  def test_render_with_layout
    get '/layout'
    assert last_response.body.include?("<html>")
    assert last_response.body.include?("Hello from view")
  end

  def test_send_tilt_options_to_render
    get '/view_with_option_trim'
    assert_equal "hello\n", last_response.body
  end
end
