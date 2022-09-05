# train-rest - Train transport

Provides a transport to communicate easily with RESTful APIs.

## Requirements

- Gem `rest-client` in Version 2.1
- Gem `awssig-v4`

## Installation

The gem can be installed  from RubyGems or built locally with an included Rake task:

```bash
rake install:local
```

## Transport parameters

| Option               | Explanation                             | Default     |
| -------------------- | --------------------------------------- | ----------- |
| `endpoint`           | Endpoint of the REST API                | _required_  |
| `verify_ssl`         | Check certificate and chain             | true        |
| `auth_type`          | Authentication type                     | `anonymous` |
| `debug_rest`         | Enable debugging of HTTP traffic        | false       |
| `logger`             | Alternative logging class               |             |

## Authenticators

### Anonymous

Identifier: `auth_type: :anonymous`

No actions for authentication, logging in/out or session handing are made. This
assumes a public API.

### Authtype Apikey

This will inject a HTTP header `Authorization: Apikey xxxx` with the passed
API key into requests.

Identifier: `auth_type: :authtype_apikey`

| Option               | Explanation                             | Default     |
| -------------------- | --------------------------------------- | ----------- |
| `apikey`             | API Key for authentication              | _required_  |

### AWS Signature v4

Identifier: `auth_type: :awsv4`

| Option              | Explanation                   | Default                  |
| ------------------- | ----------------------------- | ------------------------ |
| `credentials`       | Type of credentials to use    | `access_keys`            |
| `access_key`        | ID of the access key          | ENV: `ACCESS_KEY_ID`     |
| `secret_access_key` | Secret part of the access key | ENV: `SECRET_ACCESS_KEY` |

Only `access_keys` are supported as a credential currently. Support for other types,
like EC2 roles, is planned.

Access key and secret access key are pulled from the mentioned environment variables,
if they are not provided.

### Basic (RFC 2617)

Identifier: `auth_type: :basic`

| Option               | Explanation                             | Default     |
| -------------------- | --------------------------------------- | ----------- |
| `username`           | Username for `basic` authentication     | _required_  |
| `password`           | Password for `basic` authentication     | _required_  |

If you supply a `username` and a `password`, authentication will automatically
switch to `basic`.

### Bearer (RFC 7650)

This will inject a HTTP header `Authorization: Bearer xxxx` with the passed
token into requests.

Identifier: `auth_type: :bearer`

| Option               | Explanation                             | Default     |
| -------------------- | --------------------------------------- | ----------- |
| `token`              | Token to pass                          | _required_  |

### Header-based

This will inject an additional HTTP header with the passed value. If no name
for the header is passed, it will default to `X-API-Key`.

Identifier: `auth_type: :header`

| Option               | Explanation                             | Default     |
| -------------------- | --------------------------------------- | ----------- |
| `apikey`             | API Key for authentication              | _required_  |
| `header`             | Name of the HTTP header to include      | `X-API-Key` |

### HMAC Signature

Identifier: `auth_type: :hmac_signature`

| Option               | Explanation                             | Default       |
| -------------------- | --------------------------------------- | ------------- |
| `hmac_secret`        | Shared secret to use for signing   on   | _required_    |
| `header`             | Name of header to add                   | `X-Signature` |
| `digest`             | OpenSSL Digest type supported by Ruby   | `SHA256`      |

This will use the request body (payload) and sign it using HMAC. For a full list of
supported digest, look at [the Ruby documentation](https://ruby-doc.org/stdlib-2.7.0/libdoc/openssl/rdoc/OpenSSL/Digest.html)

### Redfish

Identifier: `auth_type: :redfish`

| Option               | Explanation                             | Default     |
| -------------------- | --------------------------------------- | ----------- |
| `username`           | Username for `redfish` authentication   | _required_  |
| `password`           | Password for `redfish` authentication   | _required_  |

For access to integrated management controllers on standardized server hardware.
The Redfish standard is defined in <http://www.dmtf.org/standards/redfish> and
this handler does initial login, reuses the received session and logs out when
closing the transport cleanly.

Known vendors which implement RedFish based management for their systems include
HPE, Dell, IBM, SuperMicro, Lenovo, Huawei and others.

## Debugging and use in Chef Infra

You can activate debugging by setting the `debug_rest` flag to `true'. Please
note, that this will also log any confidential parts of HTTP traffic as well.

For better integration into Chef Infra custom resources, all REST debug output will
be printed on `info` level. This allows debugging Chef Infra resources without
crawling through all other debug output:

```ruby
train  = Train.create('rest', {
            endpoint:   'https://api.example.com/v1/',
            debug_rest: true,
            logger:     Chef::Log
         })
```

## Request Methods

This transport does not implement the `run_command` method, as there is no
line-based protocol to execute commands against. Instead, it implements its own
custom methods which suit REST interfaces. Trying to call this method will
throw an Exception.

### Generic Request

The `request` method allows sending free-form requests against any defined or
custom methods.

`request(path, method = :get, request_parameters: {}, data: nil, headers: {},
json_processing: true)`

- `path`: The path to request, which will be appended to the `endpoint`
- `method`: The HTTP method in Ruby Symbol syntax
- `request_parameters`: A hash of parameters to the `rest-client` request
  method for additional settings
- `data`: Data for actions like `:post` or `:put`. Not all methods accept
  a data body.
- `headers`: Additional headers for the request
- `json_processing`: If the response is a JSON and you want to receive a
  processed Hash/Array instead of text

For `request_parameters` and `headers`, there is data mixed in to add
authenticator responses, JSON processing etc. Please check the
implementation in `connection.rb` for details.

### Convenience Methods

Simplified wrappers are generated for the most common request types:

- `delete(path, request_parameters: {}, headers: {}, json_processing: true)`
- `head(path, request_parameters: {}, headers: {}, json_processing: true)`
- `get(path, request_parameters: {}, headers: {}, json_processing: true)`
- `post(path, request_parameters: {}, data: nil, headers: {}, json_processing: true)`
- `put(path, request_parameters: {}, data: nil, headers: {}, json_processing: true)`
- `patch(path, request_parameters: {}, data: nil, headers: {}, json_processing: true)`

## Example use

```ruby
require 'train-rest'

train  = Train.create('rest', {
            endpoint: 'https://api.example.com/v1/',

            logger:   Logger.new($stdout, level: :info)
         })
conn   = train.connection

# Get some hypothetical data
data   = conn.get('device/1/settings')

# Modify + Patch
data['disabled'] = false
conn.patch('device/1/settings', data)

conn.close
```

Example for basic authentication:

```ruby
require 'train-rest'

# This will immediately do a login and add headers
train  = Train.create('rest', {
            endpoint: 'https://api.example.com/v1/',

            auth_type: :basic,
            username: 'admin',
            password: '*********'
         })
conn   = train.connection

# ... do work, each request will resend Basic authentication headers ...

conn.close
```

Example for logging into a RedFish based system. Please note that the RedFish
authentication handler will append `redfish/v1` to the endpoint automatically,
if it is not present.

Due to this, you can use RedFish systems either with a base URL like in the
example below or with a full one. Your own code needs to match the style
you choose.

```ruby
require 'train-rest'

# This will immediately do a login and add headers
train  = Train.create('rest', {
            endpoint: 'https://10.20.30.40',
            verify_ssl: false,

            auth_type: :redfish,
            username: 'iloadmin',
            password: '*********'
         })
conn   = train.connection

# ... do work ...

# Handles logout as well
conn.close
```

## Use with Redfish, Your Custom Resources and Chef Infra Target Mode

1. Set up a credentials file under `~/.chef/credentials` or `/etc/chef/credentials`:

   ```toml
   ['10.0.0.1']
   endpoint = 'https://10.0.0.1/redfish/v1/'
   username = 'user'
   password = 'pass'
   verify_ssl = false
   auth_type = 'redfish'
   ```

1. Configure Chef Infra to use the REST transport in `client.rb`:

   ```toml
   target_mode.protocol = "rest"
   ```

1. Write your custom resources for REST APIs
1. Mark them up using the REST methods for target mode:

   ```ruby
   provides :rest_resource, target_mode: true, platform: 'rest'
   ```

1. Run against the defined targets via Chef Infra Target Mode:

   ```shell
   chef-client --local-mode --target 10.0.0.1 --runlist 'recipe[my-cookbook::setup]'
   ```

## Use with Prerecorded API responses

For testing during and after development, not all APIs can be used to verify your solution against.
The VCR gem offers the possibility to hook into web requests and intercept them to playback canned
responses.

Please read the documentation of the VCR gem on how to record your API and the concepts like
"cassettes", "libraries" and matchers.

The following options are available in train-rest for this:

| Option               | Explanation                             | Default      |
| -------------------- | --------------------------------------- | ------------ |
| `vcr_cassette`       | Name of the response file               | nil          |
| `vcr_library`        | Directory to search responses in        | `vcr`        |
| `vcr_match_on`       | Elements to match request by            | `method uri` |
| `vcr_record`         | Recording mode                          | `none`       |
| `vcr_hook_into`      | Base library for intercepting           | `webmock`    |

VCR will only be required as a Gem and activated, if you supply a cassette name.

You can use all these settings in your Chef Infra Target Mode `credentials` file as well.
