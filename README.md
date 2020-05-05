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

Example for logging into a RedFish based system:

```ruby
require 'train-rest'

# This will immediately do a login and add headers
train  = Train.create('rest', {
            endpoint: 'https://api.example.com/v1/',
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
