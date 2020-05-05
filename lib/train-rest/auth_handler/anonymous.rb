require_relative "../auth_handler.rb"

module TrainPlugins
  module Rest
    # No Authentication
    class Anonymous < AuthHandler; end
  end
end
