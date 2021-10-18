# Changelog

## Version 0.4.0

- Add session renewal capabilities for auth_handlers
- Add interface to switch auth_handlers on-the-fly
- Add #override_headers to programmatically add more headers
- Add new auth handlers for `Bearer`, `Authorization Apikey`, `Header`
- Add some reference pointers for authentication
- Fix auth handler IDs for multi word class names

## Version 0.3.2

- Fix `patch`, `post` and `put` methods to accept keyword arguments properly

## Version 0.3.1

- Fix basic authentication
- Fix output of login/logout messages on basic authentication
- Fix handling of GET requests and null payloads
- Fix style

## Version 0.3.0

- Add VCR options for mocking API responses in development/test

## Version 0.2.1

- Fix RedFish handler for bare (non-prefixed) URLs
- Add logging of auth handlers
- Add support for a `target` flag to work with Ohai
- Fix reported platform hierarchy

## Version 0.2.0

- Add support for being used in Chef Target Mode as well

## Version 0.1.0

- Initial version
