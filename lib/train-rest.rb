libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require "train-rest/errors"
require "train-rest/version"

require "train-rest/transport"
require "train-rest/connection"

require "train-rest/auth_handler"
require "train-rest/auth_handler/awsv4"
require "train-rest/auth_handler/anonymous"
require "train-rest/auth_handler/authtype-apikey"
require "train-rest/auth_handler/basic"
require "train-rest/auth_handler/bearer"
require "train-rest/auth_handler/header"
require "train-rest/auth_handler/hmac-signature"
require "train-rest/auth_handler/redfish"
