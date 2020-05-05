require "json"
require "ostruct"
require "uri"

require "rest-client"
require "train"

module TrainPlugins
  module Rest
    class Connection < Train::Plugins::Transport::BaseConnection
      attr_reader :options

      def initialize(options)
        super(options)

        connect
      end

      def connect
        login if auth_handlers.include? auth_type
      end

      def close
        logout if auth_handlers.include? auth_type
      end

      def uri
        components = URI.new(options[:endpoint])
        components.scheme = "rest"
        components.to_s
      end

      def platform
        force_platform!("rest", { endpoint: uri })
      end

      # User-faced API

      def get(path, *parameters)
        request(path, :get, *parameters)
      end

      def post(path, *parameters)
        request(path, :post, *parameters)
      end

      def put(path, *parameters)
        request(path, :put, *parameters)
      end

      def patch(path, *parameters)
        request(path, :patch, *parameters)
      end

      def delete(path, *parameters)
        request(path, :delete, *parameters)
      end

      def request(path, method = :get, request_parameters: {}, data: nil, headers: {})
        parameters = global_parameters.merge(request_parameters)

        parameters[:method] = method
        parameters[:payload] = JSON.generate(data)
        parameters[:url] = full_url(path)

        parameters[:headers].merge! headers

        response = RestClient::Request.execute(parameters)
        transform_response(response)
      end

      # Auth Handlers-faced API

      def auth_parameters
        auth_handler.auth_parameters
      end

      private

      def global_parameters
        params = {
          verify_ssl: options[:verify_ssl] ? OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE,
          timeout: options[:timeout],
          proxy: options[:proxy],
          headers: options[:headers],
        }

        params.merge!(auth_parameters)

        params
      end

      def full_url(path)
        (URI(@options[:endpoint]) + path).to_s
      end

      def transform_response(response)
        OpenStruct.new(
          code: response.code,
          headers: response.raw_headers,
          data: JSON.load(response.to_s),
          duration: response.duration
        )
      end

      def auth_type
        return options[:auth_type] if options[:auth_type]

        :basic if options[:username] && options[:password]
      end

      attr_writer :auth_handler

      def auth_handler_classes
        AuthHandler.descendants
      end

      def auth_handlers
        auth_handler_classes.map { |handler| handler.name.to_sym }
      end

      def auth_handler
        desired_handler = auth_handler_classes.detect { |handler| handler.name == auth_type.to_s }
        raise NameError.new(format("Authentication handler %s not found", auth_type.to_s)) unless desired_handler

        @auth_handler ||= desired_handler.new(self)
      end

      def login
        auth_handler.options = options
        auth_handler.login
      end

      def logout
        auth_handler.logout
      end
    end
  end
end
