require "train-rest/connection"

module TrainPlugins
  module Rest
    class Transport < Train.plugin(1)
      name "rest"

      option :endpoint, required: true
      option :verify_ssl, default: true
      option :proxy, default: nil
      option :headers, default: nil
      option :timeout, default: 120

      option :auth_type, default: :anonymous
      option :username, default: nil
      option :password, default: nil

      def connection(_instance_opts = nil)
        @connection ||= TrainPlugins::Rest::Connection.new(@options)
      end
    end
  end
end
