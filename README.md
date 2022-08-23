# AffiliationId

AffiliationId is a middleware collection for different frameworks and gems with the purpose of making end-to-end request tracing as easy as possible.

The concept is really simple and it's meant to work like this:

1. A request that reaches a web app or API it's the entry point and should have a unique ID.
2. That ID is propagated throughout the app in all parts that are a consequence of the initial request, things like: requests to third-party APIs, Sidekiq jobs, error trackers, etc.
3. The ID is included in  all the logs statements so they can be traced based on the ID

Although there are tools like [OpenTelemetry](https://opentelemetry.io/), which is great, that is a much more complex tool and brings a lot of overhead that maybe is not worth it for some applications or teams.

Currently implemented middleware:

- Rack
- Rails
- Faraday
- Sidekiq

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'affiliation_id'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install affiliation_id

## Usage

Under the hood AffiliationId uses `SecureRandom.uuid` to generate unique ID's when needed.

```ruby
# Get current ID
AffiliationId.current_id
=> '93f971bb-b889-4223-ac57-5d39f34051a4'
```

`.current_id` is memoized and subsequent calls will return the same value

```ruby
# Set ID
AffiliationId.current_id = 'myID'

AffiliationId.current_id
=> 'myID'
```

```ruby
# Overwrite current_id with a new generated value
AffiliationId.current_id
=> '93f971bb-b889-4223-ac57-5d39f34051a4'

AffiliationId.renew_current_id!
=>'55e94f67-5fce-4226-98d5-4c149684debe'

AffiliationId.current_id
=> '55e94f67-5fce-4226-98d5-4c149684debe'
```

```ruby
# Reset/Clear current_id

AffiliationId.current_id
=> '55e94f67-5fce-4226-98d5-4c149684debe'

AffiliationId.reset!
=> nil
```

### Rack

The middleware for rack based applications is inspired from the Rails version of this middleware [ActionDispatch::RequestId](https://api.rubyonrails.org/classes/ActionDispatch/RequestId.html).

It looks at the `X-Affiliation-ID`, if the header is found and a value is present, this will be set as the `Affiliation.current_id` throughout the request, otherwise an random ID is generated.

To use the middleware, it needs to be added to the app middleware stack.

```ruby
# config.ru
require 'affiliation_id/middleware/rack'

use AffiliationId::Middleware::Rack

run MyApp.new
```

### Rails

In true Rails fashion, this works out of the box after installing the gem. Although it still depends on [ActionDispatch::RequestId](https://api.rubyonrails.org/classes/ActionDispatch/RequestId.html) which is included by default in all new Rails apps.

### Faraday

By using the Faraday middleware the, all requests will include a header `X-Affiliation-ID` with the value of `AffiliationID.current_id`.

```ruby
require 'affiliation_id/middleware/faraday'

# ...

conn = Faraday.new do |f|
  f.request :affiliation_id # include AffiliationID.current_id in the request headers
  f.adapter :net_http # Use the Net::HTTP adapter
end
```

### Sidekiq

For more information on how [Sidekiq Middleware](https://github.com/mperham/sidekiq/wiki/Middleware) works, I suggest reading id directly from the Sidekiq documentation.

Configuration example:

```ruby
# sidekiq_initializer.rb

require 'affiliation_id/middleware/sidekiq_client'
require 'affiliation_id/middleware/sidekiq_server'

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add AffiliationId::Middleware::SidekiqClient
  end
end

Sidekiq.configure_server do |config|
  config.client_middleware do |chain|
    chain.add AffiliationId::Middleware::SidekiqClient
  end
  config.server_middleware do |chain|
    chain.add AffiliationId::Middleware::SidekiqServer
  end
end
```

## Configuration

```ruby
# affiliation_id_initializer.rb

AffiliationId.configure do |config|
  # By default AffiliationId.current_id will raise an AffiliationId::MissingCurrentId exception if the value was not previously set.
  # To opt in to the behavior of generating the id automatically config the following setting to false.
  # config.enforce_explicit_current_id = false (Default: true)
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/siklodi-mariusz/affiliation_id. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/siklodi-mariusz/affiliation_id/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the AffiliationId project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/siklodi-mariusz/affiliation_id/blob/main/CODE_OF_CONDUCT.md).
