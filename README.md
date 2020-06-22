# train-rest - Train transport

Provides a transport to communicate easily with RESTful APIs.

## Requirements

- Gem `rest-client` in Version 2.1

## Installation

You will have to build this gem yourself to install it as it is not yet on
Rubygems.Org. For this there is a rake task which makes this a one-liner:

```bash
rake install:local
```

## Transport parameters

| Option               | Explanation                             | Default     |
| -------------------- | --------------------------------------- | ----------- |
| `endpoint`           | Endpoint of the REST API                | _required_  |
| `validate_ssl`       | Check certificate and chain             | true        |
| `auth_type`          | Authentication type                     | `anonymous` |
| `debug_rest`         | Enable debugging of HTTP traffic        | false       |
| `logger`             | Alternative logging class               |             |

## Authenticators

### Anonymous

Identifier: `auth_type: :anonymous`

No actions for authentication, logging in/out or session handing are made. This
assumes a public API.

### Basic Authentication

Identifier: `auth_type: :basic`

| Option               | Explanation                             | Default     |
| -------------------- | --------------------------------------- | ----------- |
| `username`           | Username for `basic` authentication     | _required_  |
| `password`           | Password for `basic` authentication     | _required_  |

If you supply a `username` and a `password`, authentication will automatically
switch to `basic`.

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

## Debugging and use in Chef

You can activate debugging by setting the `debug_rest` flag to `true'. Please
note, that this will also log any confidential parts of HTTP traffic as well.

For better integration into Chef custom resources, all REST debug output will
be printed on `info` level. This allows debugging Chef resources without
crawling through all other debug output:

```ruby
train  = Train.create('rest', {
            endpoint:   'https://api.example.com/v1/',
            debug_rest: true,
            logger:     Chef::Log
         })
```

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
            validate_ssl: false,

            auth_type: :redfish,
            username: 'iloadmin',
            password: '*********'
         })
conn   = train.connection

# ... do work ...

# Handles logout as well
conn.close
```

## Use with Redfish, Your Custom Resources and Chef Target Mode

1. Set up a credentials file under `~/.chef/credentials` or `/etc/chef/credentials`:

   ```toml
   ['10.0.0.1']
   endpoint = 'https://10.0.0.1/redfish/v1/'
   username = 'user'
   password = 'pass'
   verify_ssl = false
   auth_type = 'redfish'
   ```

1. Configure Chef to use the REST transport in `client.rb`:

   ```toml
   target_mode.protocol = "rest"
   ```

1. Write your custom resources for REST APIs
1. Mark them up using the REST methods for target mode:

   ```ruby
   provides :rest_resource, target_mode: true, platform: 'rest'
   ```

1. Run against the defiend targets via Chef Target Mode:

   ```shell
   chef-client --local-mode --target 10.0.0.1 --runlist 'recipe[my-cookbook:setup]'
   ```
