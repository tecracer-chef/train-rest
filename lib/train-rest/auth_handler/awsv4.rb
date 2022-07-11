require 'aws-sigv4'

require_relative "../auth_handler"

module TrainPlugins
  module Rest
    class AWSV4 < AuthHandler
      VALID_CREDENTIALS = %w[
        access_keys
      ].freeze

      def check_options
        options[:credentials] ||= "access_keys"

        unless VALID_CREDENTIALS.include? credentials
          raise ArgumentError.new("Invalid type of credentials: #{credentials}")
        end

        if access_keys?
          raise ArgumentError.new('Missing `access_key` credential') unless access_key
          raise ArgumentError.new('Missing `secret_access_key` credential') unless secret_access_key
        end
      end

      def signature_based?
        true
      end

      def process(payload: "", headers: {}, url: "", method: nil)
        signature = signer(url).sign_request(
          http_method: method.to_s.upcase,
          url: url,
          headers: headers,
          body: payload
        )

        {
          headers: signature.headers
        }
      end

      private

      def credentials
        options[:credentials]
      end

      def access_keys?
        credentials == 'access_keys'
      end

      def access_key
        options[:access_key] || ENV['AWS_ACCESS_KEY_ID']
      end

      def secret_access_key
        options[:secret_access_key] || ENV['AWS_SECRET_ACCESS_KEY']
      end

      def service(url)
        url.split('.').at(0)
      end

      def region(url)
        url.split('.').at(1)
      end

      def signer(url)
        Aws::Sigv4::Signer.new(
          service: service(url),
          region:  region(url),

          **signer_credentials
        )
      end

      def signer_credentials
        if access_keys?
          {
            access_key_id: access_key,
            secret_access_key: secret_access_key
          }
        end
      end
    end
  end
end
