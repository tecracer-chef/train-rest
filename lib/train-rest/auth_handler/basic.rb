require "base64" unless defined?(Base64)

require_relative "../auth_handler"

module TrainPlugins
  module Rest
    # Authentication via HTTP Basic Authentication
    class Basic < AuthHandler
      def check_options
        raise ArgumentError.new("Need username for Basic authentication") unless options[:username]
        raise ArgumentError.new("Need password for Basic authentication") unless options[:password]
      end

      def auth_parameters
        {
          headers: {
            "Authorization" => format("Basic %s", Base64.encode64(options[:username] + ":" + options[:password]).chomp),
          },
        }
      end
    end
  end
end
