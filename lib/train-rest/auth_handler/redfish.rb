require_relative "../auth_handler.rb"

module TrainPlugins
  module Rest
    # Authentication and Session handling for the Redfish 1.0 API
    #
    # @see http://www.dmtf.org/standards/redfish
    class Redfish < AuthHandler
      def check_options
        raise ArgumentError.new("Need username for Redfish authentication") unless options[:username]
        raise ArgumentError.new("Need password for Redfish authentication") unless options[:password]
      end

      def login
        response = connection.post(
          "SessionService/Sessions/",
          headers: {
            "Content-Type" => "application/json",
            "OData-Version" => "4.0",
          },
          data: {
            "UserName" => options[:username],
            "Password" => options[:password],
          }
        )

        raise StandardError.new("Authentication with Redfish failed") unless response.code === 201

        @session_token = response.headers["x-auth-token"].first
        @logout_url = response.headers["location"].first
      end

      def logout
        connection.request(
          :delete,
          @logout_url
        )
      end

      def auth_headers
        return {} unless @session_token

        { "X-Auth-Token": @session_token }
      end
    end
  end
end
