require 'thread'
require 'tilt'

module Nancy
  class Base
    REQUEST_METHODS = %w(GET POST PATCH PUT DELETE)

    class << self
      REQUEST_METHODS.each do |verb|
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

    def self.redirect(uri, status = 302)
      response.redirect(uri, status)
    end

    def self.use(*args, &block)
      middlewares << [*args, block]
    end

    def self.middlewares
      @middlewares ||= []
    end

    def initialize
      klass = self.class
      @app = Rack::Builder.new do
        klass.middlewares.each do |middleware|
          *args, block = middleware[0], middleware[1]
          use(*args){ yield block if block}
        end
        run klass
      end
    end

    def call(env)
      @app.call(env)
    end

    def self.call(env)
      Thread.current[:request] = Rack::Request.new(env)
      Thread.current[:params] = request.params
      Thread.current[:response] = Rack::Response.new
      route_set[request.request_method].each do |matcher, block|
        if match = request.path_info.match(matcher[0])
          if (captures = match.captures) && !captures.empty?
            url_params = Hash[*matcher[1].zip(captures).flatten]
            Thread.current[:params] = url_params.merge(params)
          end
          break response.write(block.call)
        end
      end

      response.status = 404 if response.empty?
      response.finish
    end

    def self.ivars
      Hash[instance_variables.map{ |name| [name, instance_variable_get(name)] }]
    end

    def self.render(template, locals = ivars, options = {}, &block)
      Tilt.new(template).render(self, locals, &block)
    end
  end
end
