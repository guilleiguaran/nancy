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
        define_method(filter) do |pattern = nil, &block|
          filters[filter.to_sym] << [pattern && compile(pattern), block]
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
        @filters ||= Hash.new { |hash, key| hash[key] = [] }
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

    def filter_eval(key, reverse: false)
      filters = self.class.filters[key]
      filters = filters.reverse if reverse

      filters.each do |matcher, block|
        if matcher.nil?
          instance_eval(&block)
          next
        end

        if (p = matcher.params(request.path_info))
          instance_exec(p, &block)
          next
        end
      end
    end

    def action_eval(block)
      filter_eval(:before)
      response.write instance_eval(&block)
      filter_eval(:after, reverse: true)
    end

  end
end
