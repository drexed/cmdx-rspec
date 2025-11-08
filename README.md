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

  # Default result
  expect(result).to have_been_skipped

  # Custom result
  expect(result).to have_been_skipped(reason: "Skipping for a custom reason")
end
```

### have_been_failure

Asserts that a CMDx task result indicates execution failure.

```ruby
it "returns failure" do
  result = SomeTask.execute

  # Default result
  expect(result).to have_been_failure

  # Custom result
  expect(result).to have_been_failure(reason: "Failed for a custom reason")
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

  # Your specs...
end
```

### Stubs

Helper methods for stubbing CMDx command execution.

### Execution types

```ruby
it "stubs task executions by type" do
  # eg: MyCommand.execute
  stub_task_success(MyCommand)
  stub_task_skip(MyCommand)
  stub_task_fail(MyCommand)

  # eg: MyCommand.execute!
  stub_task_success!(MyCommand)
  stub_task_skip!(MyCommand)
  stub_task_fail!(MyCommand)

  # Your specs...
end
```

### Options

```ruby
it "stubs task with arguments" do
  # eg: MyCommand.execute(some: "value")
  stub_task_success(MyCommand, some: "value")

  # eg: MyCommand.execute!(some: "value")
  stub_task_skip!(MyCommand, some: "value")

  # Your specs...
end
```

```ruby
it "stubs task with metadata" do
  stub_task_success(MyCommand, metadata: { some: "value" })

  # Your specs...
end

it "stubs task with a custom reason" do
  stub_task_skip!(MyCommand, reason: "Skipping for a custom reason")

  # Your specs...
end

it "stubs task with a custom cause" do
  stub_task_fail!(MyCommand, cause: NoMethodError.new("just blow it up"))

  # Your specs...
end
```

### Mocks

Helper methods for setting expectations on CMDx command execution.

### Execution types

```ruby
it "mocks task executions by type" do
  # eg: MyCommand.execute
  expect_task_execution(MyCommand)

  # eg: MyCommand.execute!
  expect_task_execution!(BangCommand)

  # Your specs...
end
```

### Options

```ruby
it "mocks task with arguments" do
  # eg: MyCommand.execute(some: "value")
  expect_task_execution(MyCommand, some: "value")

  # eg: MyCommand.execute!(some: "value")
  expect_task_execution!(MyCommand, some: "value")

  # Your specs...
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
