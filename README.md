<div align="center">
  <img src="./src/cmdx-light-logo.png#gh-light-mode-only" width="200" alt="CMDx Logo">
  <img src="./src/cmdx-dark-logo.png#gh-dark-mode-only" width="200" alt="CMDx Logo">

  ---

  Collection of RSpec matchers for the CMDx framework.

  [Changelog](./CHANGELOG.md) · [Report Bug](https://github.com/drexed/cmdx-rspec/issues) · [Request Feature](https://github.com/drexed/cmdx-rspec/issues)

  <img alt="Version" src="https://img.shields.io/gem/v/cmdx-rspec">
  <img alt="Build" src="https://github.com/drexed/cmdx-rspec/actions/workflows/ci.yml/badge.svg">
  <img alt="License" src="https://img.shields.io/github/license/drexed/cmdx-rspec">
</div>

# CMDx::RSpec

Collection of RSpec matchers for [CMDx](https://github.com/drexed/cmdx).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cmdx-rspec'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cmdx-rspec

## Matchers

### have_been_success

Asserts that a CMDx task result indicates successful execution.

```ruby
it "returns success" do
  result = SomeTask.execute

  expect(result).to have_been_success
end
```

### have_been_skipped

Asserts that a CMDx task result indicates the task was skipped during execution.

```ruby
it "returns skipped" do
  result = SomeTask.execute

  expect(result).to have_been_skipped
end
```

### have_been_failure

Asserts that a CMDx task result indicates execution failure.

```ruby
it "returns failure" do
  result = SomeTask.execute

  expect(result).to have_been_failure
end
```

### have_empty_metadata

Asserts that a CMDx task result has no metadata.

```ruby
it "returns empty metadata" do
  result = SomeTask.execute

  expect(result).to have_empty_metadata
end
```

### have_matching_metadata

Asserts that a CMDx task result contains specific metadata.

```ruby
it "returns matching metadata" do
  result = SomeTask.execute

  expect(result).to have_matching_metadata(status_code: 500)
end
```

### have_empty_context

Asserts that a CMDx task result has no context data.

```ruby
it "returns empty context" do
  result = SomeTask.execute

  expect(result).to have_empty_context
end
```

### have_matching_context

Asserts that a CMDx task result contains specific context data.

```ruby
it "returns matching context" do
  result = SomeTask.execute

  expect(result).to have_matching_context(stored_result: 123)
end
```

### be_deprecated

Asserts that a CMDx task result indicates the task is deprecated.

```ruby
it "returns deprecated" do
  result = SomeTask.execute

  expect(result).to be_deprecated
end
```

## Helpers

### Including Helper Modules

Include the helper modules in your RSpec configuration or example groups:

```ruby
RSpec.configure do |config|
  config.include CMDx::RSpec::Helpers
end
```

Or include them in specific example groups:

```ruby
describe MyFeature do
  include CMDx::RSpec::Helpers

  # your specs
end
```

### Stubs

Helper methods for stubbing CMDx command execution.

```ruby
it "stubs task executions" do
  # Success
  allow_success(SoftCommand)
  allow_success!(BangCommand, user_id: 123)

  # Skipped
  allow_skip(SoftCommand)
  allow_skip!(BangCommand, reason: "Skipped for testing", user_id: 123)

  # Failed
  allow_failure(SoftCommand)
  allow_failure!(BangCommand, reason: "Failed for testing", user_id: 123)
end
```

### Mocks

Helper methods for setting expectations on CMDx command execution.

```ruby
it "mocks task executions" do
  expect_execute(SoftCommand)
  expect_execute!(BangCommand, user_id: 123)
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/drexed/cmdx-rspec. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/drexed/cmdx-rspec/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Cmdx::Rspec project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/drexed/cmdx-rspec/blob/master/CODE_OF_CONDUCT.md).
