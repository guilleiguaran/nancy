require 'rack'
require 'tilt'

module Nancy
  class Base
    class << self
      %w(GET POST PATCH PUT DELETE).each do |verb|
        define_method(verb.downcase) do |pattern, &block|
          route_set[verb] << [compile(pattern), block]
        end
      end
    end

    def self.compile(pattern)
      keys = []
      pattern.gsub!(/(:\w+)/) do |match|
        keys << $1[1..-1]
        "([^/?#]+)"
      end
      [%r{^#{pattern}$}, keys]
    end

    def self.route_set
      @route_set ||= Hash.new { |h, k| h[k] = [] }
    end

    class << self
      %w(request response params).each do |accessor|
        define_method(accessor){ Thread.current[accessor.to_sym] }
      end
    end

    def self.session
      request.env["rack.session"]
    end

    def self.redirect(uri)
      halt 302, {"Location" => uri}
    end

    def self.use(middleware, *args, &block)
      middlewares << [middleware, *args, block]
    end

    def self.middlewares
      @middlewares ||= []
    end

    def initialize
      klass = self.class
      @app = Rack::Builder.new do
        klass.middlewares.each do |middleware|
          middleware, *args, block = middleware
          use(middleware, *args, &block)
        end
        run klass
      end
    end

    def call(env)
      @app.call(env)
    end

    def self.call(env)
      Thread.current[:request] = Rack::Request.new(env)
      Thread.current[:response] = Rack::Response.new
      Thread.current[:params] = request.params
      response = catch(:halt) do
        route_eval(request.request_method, request.path_info)
      end.finish
    end

    def self.route_eval(request_method, path_info)
      route_set[request_method].each do |matcher, block|
        if match = path_info.match(matcher[0])
          if (captures = match.captures) && !captures.empty?
            url_params = Hash[*matcher[1].zip(captures).flatten]
            Thread.current[:params] = url_params.merge(params)
          end
          response.write(block.call)
          halt response
        end
      end
      halt 404
    end

    def self.halt(*res)
      throw :halt, res.first if res.first.is_a?(Rack::Response)
      response.status = res.select{|x| x.is_a?(Fixnum)}.first || 200
      headers = res.select{|x| x.is_a?(Hash)}.first || {}
      response.header.merge!(headers)
      response.body = [(res.select{|x| x.is_a?(String)}.first || "")]
      throw :halt, response
    end

    def self.render(template, locals = {}, options = {}, &block)
      Tilt.new(template).render(self, locals, &block)
    end
  end
end
