libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require "train-rest/version"

require "train-rest/transport"
require "train-rest/connection"

require "train-rest/auth_handler/anonymous"
require "train-rest/auth_handler/basic"
require "train-rest/auth_handler/redfish"
