require_relative "../auth_handler"

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
          login_url,
          headers: {
            "Content-Type" => "application/json",
            "OData-Version" => "4.0",
          },
          data: {
            "UserName" => options[:username],
            "Password" => options[:password],
          }
        )

        @session_token = response.headers["x-auth-token"].first
        @logout_url = response.headers["location"].first

      rescue ::RestClient::RequestFailed => err
        raise StandardError.new("Authentication with Redfish failed: " + err.message)
      end

      def logout
        connection.delete(@logout_url)
      end

      def auth_headers
        return {} unless @session_token

        { "X-Auth-Token": @session_token }
      end

      private

      # Prepend the RedFish base, if not a global setting in the connection URL
      def login_url
        return "SessionService/Sessions/" if options[:endpoint].include?("redfish/v1")

        "redfish/v1/SessionService/Sessions/"
      end
    end
  end
end
