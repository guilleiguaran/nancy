require 'forwardable'
require 'mustermann'
require 'rack'

module Nancy
  class Base
    class << self
      extend Forwardable

      def_delegators :builder, :map, :use

      %w(GET POST PATCH PUT DELETE HEAD OPTIONS).each do |verb|
        define_method(verb.downcase) do |pattern, &block|
          route_set[verb] << [compile(pattern), block]
        end
      end

      %w(before after).each do |filter|
        define_method(filter) do |&block|
          filters[filter.to_sym] = block
        end
      end

      alias_method :new!, :new
      def new(*args, &block)
        builder.run new!(*args, &block)
        builder
      end

      def route_set
        @route_set ||= Hash.new { |hash, key| hash[key] = [] }
      end

      def filters
        @filters ||= Hash.new
      end

      private

      def compile(pattern)
        Mustermann.new(pattern)
      end

      def builder
        @builder ||= Rack::Builder.new
      end
    end

    attr_reader :request, :response, :params, :env

    def call(env)
      dup.call!(env)
    end

    def call!(env)
      env['PATH_INFO'] = '/' if env['PATH_INFO'].empty?
      @request = Rack::Request.new(env)
      @response = Rack::Response.new
      @params = request.params
      @env = env
      route_eval
      @response.finish
    end

    def session
      request.env["rack.session"] || raise("Rack::Session handler is missing")
    end

    def halt(*res)
      response.status = res.detect{|x| x.is_a?(Fixnum) } || 200
      response.header.merge!(res.detect{|x| x.is_a?(Hash) } || {})
      response.body = [res.detect{|x| x.is_a?(String) } || ""]
      throw :halt, response
    end

    private

    def route_eval
      catch(:halt) do
        self.class.route_set[request.request_method].each do |matcher, block|
          next unless url_params = matcher.params(request.path_info)
          @params = url_params.merge(params)
          return action_eval(block)
        end
        halt 404
      end
    end

    def action_eval(block)
      instance_exec(&self.class.filters[:before]) if self.class.filters[:before]
      response.write instance_eval(&block)
      instance_exec(&self.class.filters[:after]) if self.class.filters[:after]
    end

  end
end
