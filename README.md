<div align="center">
  <img src="./src/cmdx-light-logo.png#gh-light-mode-only" width="200" alt="CMDx Logo">
  <img src="./src/cmdx-dark-logo.png#gh-dark-mode-only" width="200" alt="CMDx Logo">

  ---

  Collection of RSpec matchers and helpers for the CMDx framework.

  [Changelog](./CHANGELOG.md) · [Report Bug](https://github.com/drexed/cmdx-rspec/issues) · [Request Feature](https://github.com/drexed/cmdx-rspec/issues)

  <img alt="Version" src="https://img.shields.io/gem/v/cmdx-rspec">
  <img alt="Build" src="https://github.com/drexed/cmdx-rspec/actions/workflows/ci.yml/badge.svg">
  <img alt="License" src="https://img.shields.io/github/license/drexed/cmdx-rspec">
</div>

# CMDx::RSpec

RSpec matchers and helpers for asserting [CMDx](https://github.com/drexed/cmdx) task and workflow behavior — result state, errors, faults, callbacks, retries, chains, and more — without invoking real `work` blocks.

## Requirements

- Ruby: MRI 3.3+ or a compatible JRuby/TruffleRuby release
- CMDx 2.0+

## Installation

```sh
gem install cmdx-rspec
# - or -
bundle add cmdx-rspec --group test
```

Require the library in `spec_helper.rb` (or equivalent):

```ruby
require "cmdx/rspec"
```

This loads every matcher under `RSpec::Matchers` and exposes the helpers under `CMDx::RSpec::Helpers`. See [Helpers](#helpers) for how to mix the helpers into your example groups.

## Matchers

All result-oriented matchers raise `ArgumentError` when given a subject that isn't a `CMDx::Result`. Class-oriented matchers accept either the Task class or an instance.

### Result state & status

#### `be_successful`

Asserts a `CMDx::Result` completed with `state: complete` and `status: success`. Extra keyword args are forwarded to a `result.to_h` inclusion check, so any field can be constrained inline.

```ruby
expect(SomeTask.execute).to be_successful
expect(SomeTask.execute).to be_successful(metadata: { id: 1 })
```

#### `have_skipped`

Asserts a result was skipped (`state: interrupted`, `status: skipped`). Extra keyword args constrain other `result.to_h` fields.

```ruby
expect(result).to have_skipped
expect(result).to have_skipped(
  reason: "out of stock",
  cause: be_a(CMDx::SkipFault)
)
```

#### `have_failed`

Asserts a result failed (`state: interrupted`, `status: failed`). Extra keyword args constrain other `result.to_h` fields.

```ruby
expect(result).to have_failed
expect(result).to have_failed(
  reason: "boom",
  cause: be_a(NoMethodError)
)
```

#### `be_ok` / `be_ko`

`be_ok` passes when the result is success or skipped (anything but failed). `be_ko` is its inverse.

```ruby
expect(result).to be_ok
expect(result).to be_ko
```

#### `be_complete` / `be_interrupted`

State-only assertions. `be_complete` passes when `state == :complete`; `be_interrupted` when `state == :interrupted`.

```ruby
expect(result).to be_complete
expect(result).to be_interrupted
```

### Result data

#### `have_empty_metadata` / `have_matching_metadata`

`have_empty_metadata` requires `metadata` to be empty. `have_matching_metadata` performs a partial-hash inclusion match (and delegates to `have_empty_metadata` when called with no args).

```ruby
expect(result).to have_empty_metadata
expect(result).to have_matching_metadata(status_code: 500)
```

#### `have_empty_context` / `have_matching_context`

Same pattern for the result's context. Both accept a `Hash`, `CMDx::Context`, or `CMDx::Result` (the result's `.context` is unwrapped automatically).

```ruby
expect(result).to have_empty_context
expect(result).to have_matching_context(stored_id: 123)
```

### Errors

#### `have_no_errors`

Passes when the subject's `errors` collection is empty. Accepts a `CMDx::Result`, `CMDx::Task` instance, or `CMDx::Errors`.

```ruby
expect(result).to have_no_errors
```

#### `have_errors_on`

Asserts at least one error is present under `key`. Optional positional `messages` further constrain the matcher — all must be present.

```ruby
expect(result).to have_errors_on(:email)
expect(result).to have_errors_on(:email, "is required")
expect(task).to   have_errors_on(:email, "is required", "is invalid")
```

### Execution metrics

#### `have_been_retried`

Passes when the result was retried at least once. Pass an integer to require an exact retry count.

```ruby
expect(result).to have_been_retried
expect(result).to have_been_retried(3)
```

#### `have_been_rolled_back`

Passes when a failing task ran its rollback hook.

```ruby
expect(result).to have_been_rolled_back
```

#### `have_duration`

Asserts the result's duration (in milliseconds) falls within the supplied bounds. At least one of `:less_than` or `:greater_than` is required.

```ruby
expect(result).to have_duration(less_than: 100)
expect(result).to have_duration(greater_than: 0.1, less_than: 50)
```

### Faults

#### `raise_cmdx_fault`

Block matcher that asserts a `CMDx::Fault` is raised. Optionally constrain by originating task class, reason, or underlying cause.

```ruby
expect { SomeTask.execute! }.to raise_cmdx_fault
expect { SomeTask.execute! }.to raise_cmdx_fault(SomeTask)
expect { SomeTask.execute! }
  .to raise_cmdx_fault(SomeTask)
  .with_reason(/invalid/)
  .with_cause(MyError)
```

`with_reason` accepts a string (equality) or a Regexp; `with_cause` accepts a class (matches via `is_a?`) or a value (matched with `values_match?`).

### Chains

#### `have_chain_root`

Passes when the chain's root task class matches (or is a subclass of) `task_class`. Accepts a `CMDx::Chain` or `CMDx::Result`.

```ruby
expect(result).to have_chain_root(MyWorkflow)
```

#### `have_chain_size`

Passes when the chain's size matches `expected`. Accepts a `CMDx::Chain` or `CMDx::Result`.

```ruby
expect(result).to have_chain_size(3)
```

### Task class declarations

These matchers introspect a Task class's configuration. They accept either the class or an instance.

#### `be_deprecated`

Asserts a Task class is marked deprecated. Optionally constrain the deprecation behavior via a positional value or a chained convenience method.

```ruby
expect(SomeTask).to be_deprecated
expect(SomeTask).to be_deprecated.with_warning   # :warn
expect(SomeTask).to be_deprecated.with_logging   # :log
expect(SomeTask).to be_deprecated.with_error     # :error
expect(SomeTask).to be_deprecated.with_behavior(:custom)
```

#### `have_input` / `have_output`

Asserts the class declares the given input/output. Keyword args are matched (partial) against the parameter's serialized `to_h`.

```ruby
expect(SomeTask).to have_input(:user_id)
expect(SomeTask).to have_input(:user_id, type: :integer, required: true)
expect(SomeTask).to have_output(:total, required: true)
```

#### `have_callback`

Asserts a callback is registered for `event`. Optional `callable` further constrains the match — by `==` for symbols/lambdas, or by `is_a?` when given a class.

```ruby
expect(SomeTask).to have_callback(:before_execution)
expect(SomeTask).to have_callback(:before_execution, :authenticate!)
expect(SomeTask).to have_callback(:on_failed, AlertOnFailure)
```

#### `have_middleware`

Asserts the class registered `middleware`. Class arguments match by `is_a?` or `==`; other values match by `==`.

```ruby
expect(SomeTask).to have_middleware(LoggingMiddleware)
```

#### `have_retry_on`

Asserts the class is configured to retry on `exception`. Keyword args check `CMDx::Retry` configuration values (`:limit`, `:delay`, `:max_delay`, `:jitter`).

```ruby
expect(SomeTask).to have_retry_on(Net::OpenTimeout)
expect(SomeTask).to have_retry_on(Net::OpenTimeout, limit: 5, jitter: :exponential)
```

#### `have_tag`

Asserts the subject carries `tag`. Accepts a Task class (reads `settings.tags`) or a `CMDx::Result` (reads `result.tags`).

```ruby
expect(SomeTask).to have_tag(:critical)
expect(result).to   have_tag(:critical)
```

### Workflows

#### `have_pipeline_tasks`

Asserts a `CMDx::Workflow` class declares the given pipeline tasks. Order-sensitive by default; chain `.in_any_order` for set comparison.

```ruby
expect(MyWorkflow).to have_pipeline_tasks(StepA, StepB, StepC)
expect(MyWorkflow).to have_pipeline_tasks(StepA, StepC, StepB).in_any_order
```

## Helpers

### Including helper modules

Mix into all example groups via RSpec config, or include in specific groups:

```ruby
RSpec.configure do |config|
  config.include CMDx::RSpec::Helpers
end
```

```ruby
describe MyFeature do
  include CMDx::RSpec::Helpers
  # ...
end
```

### Stubs

Each stub builds a frozen `CMDx::Result` carrying the requested signal and wires it into a fresh `CMDx::Chain`, so callers see realistic execution shape without invoking the task's `work`. Any extra keyword args (besides the documented ones) are forwarded to `command.new` as context overrides.

#### Result-type stubs

```ruby
# Non-bang variants stub `SomeTask.execute`
stub_task_success(SomeTask)
stub_task_skip(SomeTask)
stub_task_fail(SomeTask)

# Bang variants stub `SomeTask.execute!`
stub_task_success!(SomeTask)
stub_task_skip!(SomeTask)
stub_task_fail!(SomeTask)

# Stub a specific argument signature
stub_task_success(SomeTask, some: "value")        # SomeTask.execute(some: "value")
stub_task_skip!(SomeTask, some: "value")          # SomeTask.execute!(some: "value")
```

Common options:

```ruby
stub_task_success(SomeTask, metadata: { id: 1 })
stub_task_skip!(SomeTask, reason: "out of stock")
stub_task_fail!(SomeTask, cause: NoMethodError.new("boom"))
```

#### Specialized stubs

```ruby
# Models the rescued StandardError -> failed signal path that Runtime
# takes when `work` raises something other than a Fault.
stub_task_error(SomeTask, Net::OpenTimeout, "boom")

# Models the `throw!`-then-propagate path used by nested tasks/workflows.
# `upstream_result` must be a failed CMDx::Result.
stub_task_throw(SomeTask, upstream_result)

# Returns a successful Result flagged as `deprecated?` without triggering
# the real Deprecation action.
stub_task_deprecated(SomeTask)
```

#### Workflow stubs

`stub_workflow_tasks` yields each distinct Task class reachable from a Workflow's pipeline (first-seen order) so you can stub them in one place.

```ruby
stub_workflow_tasks(MyWorkflow) do |task|
  case task
  when TaskC then stub_task_skip(task)
  else            stub_task_success(task)
  end
end

MyWorkflow.execute
```

#### Unstubbing

Restores the original implementation. When `context` is supplied, only that argument signature is unstubbed.

```ruby
unstub_task(SomeTask)                # SomeTask.execute
unstub_task!(SomeTask)               # SomeTask.execute!
unstub_task(SomeTask, some: "value") # SomeTask.execute(some: "value")
```

### Mocks

Message expectations on `execute` / `execute!`. When `context` is supplied, the expectation is constrained to that signature.

```ruby
expect_task_execution(SomeTask)
expect_task_execution!(SomeTask)
expect_task_execution(SomeTask, some: "value")

expect_no_task_execution(SomeTask)
expect_no_task_execution!(SomeTask)
expect_no_task_execution(SomeTask, some: "value")
```

### Diagnostics

#### `capture_cmdx_logs`

Captures lines written to a temporary `CMDx.configuration.logger` for the duration of the block. The previous logger is restored on exit.

```ruby
logs = capture_cmdx_logs { MyCommand.execute }
expect(logs.join).to include("status=success")
```

#### `subscribe_telemetry`

Subscribes to telemetry events on a Task's telemetry registry for the duration of the block and returns every emitted event in order. Tasks subclassing `command` also fire (the registry is shared by reference until `dup`). Defaults to all events in `CMDx::Telemetry::EVENTS`.

```ruby
events = subscribe_telemetry(MyCommand, :task_executed) { MyCommand.execute }
expect(events.map(&:name)).to eq([:task_executed])
```

#### `with_cmdx_chain`

Captures the `CMDx::Chain` produced by the first root execution of `command` within the block. Returns `nil` if `command` didn't run as a root.

```ruby
chain = with_cmdx_chain(MyWorkflow) { MyWorkflow.execute }
expect(chain.size).to be > 1
```

## Development

Run `bin/setup` to install dependencies, then `rake spec` to run the tests. Use `bin/console` for an interactive prompt.

Release flow: bump `lib/cmdx/rspec/version.rb`, then `bundle exec rake release` to tag, push, and publish to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome at <https://github.com/drexed/cmdx-rspec>. Contributors are expected to follow the [code of conduct](https://github.com/drexed/cmdx-rspec/blob/master/CODE_OF_CONDUCT.md).

## License

Released under the [MIT License](https://opensource.org/licenses/MIT).
