require_relative "../auth_handler"

module TrainPlugins
  module Rest
    # Authentication via HMAC Signature.
    class HmacSignature < AuthHandler
      def check_options
        raise ArgumentError.new("Need :hmac_secret for HMAC signatures") unless options[:hmac_secret]

        options[:header] ||= "X-Signature"
        options[:digest] ||= "SHA256"
      end

      def hmac_secret
        options[:hmac_secret]
      end

      def digest
        options[:digest]
      end

      def header
        options[:header]
      end

      def signature_based?
        true
      end

      def process(payload: "", headers: {}, url: "", method: nil)
        {
          headers: {
            header => OpenSSL::HMAC.hexdigest(digest, hmac_secret, payload)
          }
        }
      end
    end
  end
end
