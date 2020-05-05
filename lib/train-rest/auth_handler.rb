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
        self.to_s.split("::").last.downcase
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

      # Handle Login
      def login; end

      # Handle Logout
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

      # List authentication handlers
      #
      # @return [Array] Classes derived from `AuthHandler`
      def self.descendants
        ObjectSpace.each_object(Class).select { |klass| klass < self }
      end
    end
  end
end
