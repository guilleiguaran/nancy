require File.expand_path("../test_helper", __FILE__)
require "nancy/basic_render"

class BasicRenderTest < Minitest::Test
  include Rack::Test::Methods

  class TestApp < Nancy::Base
    include Nancy::BasicRender

    get "/view" do
      @message = "Hello from view"
      render("#{view_path}/view.erb")
    end

    get "/layout" do
      @message = "Hello from view"
      render("#{view_path}/layout.erb") { render("#{view_path}/view.erb") }
    end

    def view_path
      File.expand_path("fixtures", Dir.pwd)
    end
  end

  def app
    TestApp.new
  end

  def test_render
    get "/view"
    assert !last_response.body.include?("<html>")
    assert last_response.body.include?("Hello from view")
  end

  def test_render_with_layout
    get "/layout"
    assert last_response.body.include?("<html>")
    assert last_response.body.include?("Hello from view")
  end
end
