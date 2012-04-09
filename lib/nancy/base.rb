require 'rack'

module Nancy
  class Base
    class << self
      %w(GET POST PATCH PUT DELETE HEAD OPTIONS).each do |verb|
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

    %w(request response params env).each do |accessor|
      define_method(accessor){ Thread.current[accessor.to_sym] }
    end

    def session
      request.env["rack.session"] || raise("Rack::Session handler is missing")
    end

    def redirect(uri)
      halt 302, {"Location" => uri}
    end

    def self.use(*args, &block)
      @builder.use(*args, &block)
    end

    def self.map(*args, &block)
      @builder.map(*args, &block)
    end

    def self.inherited(child)
      child.instance_eval do
        @builder = Rack::Builder.new
        @builder.run(child.new)
      end
    end

    def self.call(env)
      @builder.dup.call(env)
    end

    def call(env)
      Thread.current[:request] = Rack::Request.new(env)
      Thread.current[:response] = Rack::Response.new
      Thread.current[:params] = request.params
      Thread.current[:env] = env
      response = catch(:halt) do
        route_eval(request.request_method, request.path_info)
      end.finish
    end

    def route_eval(request_method, path_info)
      path_info = "/#{path_info}" unless path_info[0] == "/"
      self.class.route_set[request_method].each do |matcher, block|
        if match = path_info.match(matcher[0])
          if (captures = match.captures) && !captures.empty?
            url_params = Hash[*matcher[1].zip(captures).flatten]
            Thread.current[:params] = url_params.merge(params)
          end
          response.write instance_eval(&block)
          halt response
        end
      end
      halt 404
    end

    def halt(*res)
      throw :halt, res.first if res.first.is_a?(Rack::Response)
      response.status = res.select{|x| x.is_a?(Fixnum)}.first || 200
      headers = res.select{|x| x.is_a?(Hash)}.first || {}
      response.header.merge!(headers)
      response.body = [(res.select{|x| x.is_a?(String)}.first || "")]
      throw :halt, response
    end
  end
end
