require "base64" unless defined?(Base64)

require_relative "../auth_handler"

module TrainPlugins
  module Rest
    # Authentication via "Apikey" type in Authorization headers.
    #
    # Could not find a norm for this, just references in e.g. ElasticSearch & Cloud Conformity APIs.
    class AuthtypeApikey < AuthHandler
      def check_options
        raise ArgumentError.new("Need :apikey for `Authorization: Apikey` authentication") unless options[:apikey]
      end

      def auth_parameters
        {
          headers: {
            "Authorization" => format("Apikey %s", options[:apikey]),
          },
        }
      end
    end
  end
end
