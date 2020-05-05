require_relative "../auth_handler.rb"

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
          user: options[:username],
          password: options[:password],
        }
      end
    end
  end
end
