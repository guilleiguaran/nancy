$:.push File.expand_path("../../lib", __FILE__)

require "nancy/base"
require "nancy/render"

class MiniApp < Nancy::Base
  get("/") { "Hello from MiniApp" }
  get("/:something") { params["something"] }
end

class App < Nancy::Base
  use Rack::Runtime
  use Rack::Session::Cookie, secret: ENV["SECRET"]
  use Rack::Static, urls: ["/js"], root: "public"
  include Nancy::Render

  get "/" do
    "Hello World"
  end

  get "/hello/:name" do
    "Hello #{params["name"]}"
  end

  get "/:message/:name" do
    @message = params["message"]
    @name = params["name"]
    render "hello.erb"
  end

  post "/params/:params" do
    params.to_s
  end

  get "/redirect" do
    session["test"] = "test"
    redirect "/session"
  end

  get "/session" do
    session["test"].to_s
  end

  get "/set_session" do
    session["test"] = "test 2"
  end

  patch "/test" do
    "PATCH verb supported"
  end

  get "/layout" do
    @message = "Hola"
    @name = "Usuario"
    render("layout.erb") { render("hello.erb") }
  end

  get "/halt/404" do
    halt 404
  end

  get "/halt_error" do
    halt 500, "Error fatal"
  end

  map "/rack" do
    run lambda { |env| [200, {"Content-Type" => "text/html"}, ["PATH_INFO: #{env["PATH_INFO"]}"]] }
  end

  map "/nancy" do
    run MiniApp.new
  end

  # Helper method
  def render(*args)
    args[0] = "views/#{args[0]}"
    super(*args)
  end
end
