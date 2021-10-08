require_relative "../auth_handler"

module TrainPlugins
  module Rest
    # No Authentication
    class Anonymous < AuthHandler; end
  end
end
