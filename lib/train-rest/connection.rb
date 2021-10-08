require "json" unless defined?(JSON)
require "ostruct" unless defined?(OpenStruct)
require "uri" unless defined?(URI)

require "rest-client" unless defined?(RestClient)
require "train" unless defined?(Train)

module TrainPlugins
  module Rest
    class Connection < Train::Plugins::Transport::BaseConnection
      attr_reader :options

      def initialize(options)
        super(options)

        # Plugin was called with an URI only
        options[:endpoint] = options[:target].sub("rest://", "https://") unless options[:endpoint]

        # Accept string (CLI) and boolean (API) options
        options[:verify_ssl] = options[:verify_ssl].to_s == "false" ? false : true

        setup_vcr

        connect
      end

      def setup_vcr
        return unless options[:vcr_cassette]

        require "vcr" unless defined?(VCR)

        # TODO: Starts from "/" :(
        library = options[:vcr_library]
        match_on = options[:vcr_match_on].split.map(&:to_sym)

        VCR.configure do |config|
          config.cassette_library_dir = library
          config.hook_into options[:vcr_hook_into]
          config.default_cassette_options = {
            record: options[:vcr_record].to_sym,
            match_requests_on: match_on,
          }
        end

        VCR.insert_cassette options[:vcr_cassette]
      rescue LoadError
        logger.fatal "Install the vcr gem to use HTTP(S) playback capability"
        raise
      end

      def connect
        login if auth_handlers.include? auth_type
      end

      def close
        logout if auth_handlers.include? auth_type
      end

      def uri
        components = URI(options[:endpoint])
        components.scheme = "rest"
        components.to_s
      end

      # Allow overwriting to refine the type of REST API
      attr_writer :detected_os

      def inventory
        OpenStruct.new({
          name: @detected_os || "rest",
          release: TrainPlugins::Rest::VERSION,
          family_hierarchy: %w{rest api},
          family: "api",
          platform: "rest",
          platform_version: 0,
        })
      end

      alias os inventory

      def platform
        Train::Platforms.name("rest").in_family("api")

        force_platform!("rest", { release: TrainPlugins::Rest::VERSION })
      end

      # User-faced API

      %i{get post put patch delete head}.each do |method|
        define_method(method) do |path, *parameters|
          # TODO: "warning: Using the last argument as keyword parameters is deprecated; maybe ** should be added to the call"
          request(path, method, *parameters)
        end
      end

      def request(path, method = :get, request_parameters: {}, data: nil, headers: {}, json_processing: true)
        parameters = global_parameters.merge(request_parameters)

        parameters[:method] = method
        parameters[:url] = full_url(path)

        if json_processing
          parameters[:headers]["Accept"]       = "application/json"
          parameters[:headers]["Content-Type"] = "application/json"
          parameters[:payload] = JSON.generate(data) unless data.nil?
        else
          parameters[:payload] = data
        end

        parameters[:headers].merge! headers
        parameters.compact!

        logger.info format("[REST] => %s", parameters.to_s) if options[:debug_rest]
        response = RestClient::Request.execute(parameters)

        logger.info format("[REST] <= %s", response.to_s) if options[:debug_rest]
        transform_response(response, json_processing)
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

      def transform_response(response, json_processing = true)
        OpenStruct.new(
          code: response.code,
          headers: response.raw_headers,
          data: json_processing ? JSON.load(response.to_s) : response.to_s,
          duration: response.duration
        )
      end

      def auth_type
        return options[:auth_type].to_sym if options[:auth_type]

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
        logger.info format("REST Login via %s authentication handler", auth_type.to_s) unless %i{anonymous basic}.include? auth_type

        auth_handler.options = options
        auth_handler.login
      end

      def logout
        logger.info format("REST Logout via %s authentication handler", auth_type.to_s) unless %i{anonymous basic}.include? auth_type

        auth_handler.logout
      end
    end
  end
end
