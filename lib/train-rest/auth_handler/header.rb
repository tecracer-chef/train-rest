require_relative "../auth_handler"

module TrainPlugins
  module Rest
    # Authentication via additional Header.
    #
    # Header name defaults to "X-API-Key"
    class Header < AuthHandler
      def check_options
        raise ArgumentError.new("Need :apikey for Header-based authentication") unless options[:apikey]

        options[:header] = "X-API-Key" unless options[:header]
      end

      def auth_parameters
        {
          headers: {
            options[:header] => options[:apikey],
          },
        }
      end
    end
  end
end
