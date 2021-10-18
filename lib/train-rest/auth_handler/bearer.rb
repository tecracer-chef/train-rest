require "base64" unless defined?(Base64)

require_relative "../auth_handler"

module TrainPlugins
  module Rest
    # Authentication via Bearer Authentication.
    #
    # @see https://datatracker.ietf.org/doc/html/rfc6750#section-2.1
    class Bearer < AuthHandler
      def check_options
        raise ArgumentError.new("Need :token for Bearer authentication") unless options[:token]
      end

      def auth_parameters
        {
          headers: {
            "Authorization" => format("Bearer %s", options[:token]),
          },
        }
      end
    end
  end
end
