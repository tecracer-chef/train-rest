require "rubygems" unless defined?(Gem)

require "train-rest/connection"

module TrainPlugins
  module Rest
    class Transport < Train.plugin(1)
      name "rest"

      option :endpoint, required: true
      option :verify_ssl, default: true
      option :proxy, default: nil
      option :headers, default: {}
      option :timeout, default: 120

      option :auth_type, default: :anonymous
      option :username, default: nil
      option :password, default: nil
      option :debug_rest, default: false

      option :vcr_cassette, default: nil
      option :vcr_library, default: "vcr"
      option :vcr_match_on, default: "method uri"
      option :vcr_record, default: "none"
      option :vcr_hook_into, default: "webmock"

      def connection(_instance_opts = nil)
        dependency_checks

        @connection ||= TrainPlugins::Rest::Connection.new(@options)
      end

      private

      def dependency_checks
        return unless @options[:vcr_cassette]

        raise Gem::LoadError.new("Install VCR Gem for API playback capability") unless gem_installed?("vcr")

        stubber = @options[:vcr_hook_into]
        raise Gem::LoadError.new("Install #{stubber} Gem for API playback capability") unless gem_installed?(stubber)
      end

      def gem_installed?(name)
        Gem::Specification.find_all_by_name(name).any?
      end
    end
  end
end
