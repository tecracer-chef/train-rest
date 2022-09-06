module TrainPlugins
  module Rest
    # Class to derive authentication handlers from.
    class AuthHandler
      attr_accessor :connection
      attr_reader :options

      def initialize(connection = nil)
        @connection = connection
      end

      # Return name of handler
      #
      # @return [String]
      def self.name
        class_name = self.to_s.split("::").last

        convert_to_snake_case(class_name)
      end

      # List authentication handlers
      #
      # @return [Array] Classes derived from `AuthHandler`
      def self.descendants
        ObjectSpace.each_object(Class).select { |klass| klass < self }
      end

      # Store authenticator options and trigger validation
      #
      # @param [Hash] All transport options
      def options=(options)
        @options = options

        check_options
      end

      # Verify transport options
      # @raise [ArgumentError] if options are not as needed
      def check_options; end

      # Handle login
      def login; end

      # Handle session renewal
      def renew_session; end

      # Return if session renewal needs to happen soon
      #
      # @return [Boolean]
      def renewal_needed?; end

      # Handle logout
      def logout; end

      # Headers added to the rest-client call
      #
      # @return [Hash]
      def auth_headers
        {}
      end

      # These will get added to the rest-client call.
      #
      # @return [Hash]
      # @see https://www.rubydoc.info/gems/rest-client/RestClient/Request
      def auth_parameters
        { headers: auth_headers }
      end

      # This Auth Handler will need payload, URI and headers, e.g. for signatures.
      #
      # @return  [Boolean]
      def signature_based?
        false
      end

      # Return headers based on payload signing.
      #
      # @param [Hash] data different types of data for processing
      # @option data [String] :payload contents of the message body
      # @option data [Hash] :headers existing headers to the request
      # @option data [String] :url URL which will be requested
      # @option data [Symbol] :method Method to execute
      # @returns [Hash]
      def process(payload: "", headers: {}, url: "", method: nil)
        {}
      end

      # Allow processing errors related to authentication.
      #
      # @param [RestClient::Exception] error raw error data
      def process_error(_error); end

      class << self
        private

        # Convert a class name to snake case.
        #
        # @param [String] Class name
        # @return [String]
        # @see https://github.com/chef/chef/blob/main/lib/chef/mixin/convert_to_class_name.rb
        def convert_to_snake_case(str)
          str = str.dup
          str.gsub!(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          str.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
          str.downcase!
          str.sub!(/^\_/, "")
          str
        end
      end
    end
  end
end
