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
