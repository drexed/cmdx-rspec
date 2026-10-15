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

RSpec matchers and helpers for [CMDx](https://github.com/drexed/cmdx) tasks and workflows: stub or spy `execute` / `execute!`, build real `CMDx::Result` fixtures, assert outcomes and payloads, inspect task declarations, and capture logs and telemetry — without running collaborator `work` blocks unless you choose to.

## Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Quick start](#quick-start)
- [Core concepts](#core-concepts)
  - [What you can assert on](#what-you-can-assert-on)
  - [Choosing a result matcher](#choosing-a-result-matcher)
  - [CMDx built-in predicates vs this gem](#cmdx-built-in-predicates-vs-this-gem)
  - [Deferred result fixtures](#deferred-result-fixtures)
- [Common patterns](#common-patterns)
- [Matcher catalog](#matcher-catalog)
- [Matcher reference](#matcher-reference)
  - [Execution](#execution)
  - [Result outcomes](#result-outcomes)
  - [Result context, metadata, and errors](#result-context-metadata-and-errors)
  - [Execution metrics](#execution-metrics)
  - [Chains](#chains)
  - [Task declarations](#task-declarations)
  - [Workflows](#workflows)
  - [Block matchers](#block-matchers)
- [Result fixtures (`build_result`)](#result-fixtures-build_result)
- [Upgrading from stub helpers](#upgrading-from-stub-helpers)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)

## Requirements

- Ruby: MRI 3.3+ (or a compatible JRuby / TruffleRuby release)
- CMDx 2.0+
- RSpec 3.13+

## Installation

```sh
gem install cmdx-rspec
# - or -
bundle add cmdx-rspec --group test
```

Require the library from `spec_helper.rb` (or equivalent). Loading the gem defines matcher classes and factories; matchers are **not** mixed into examples until you `include` them.

```ruby
require "cmdx/rspec"
```

## Quick start

Include `CMDx::RSpec::Matchers` in the groups that need CMDx assertions:

```ruby
# spec/spec_helper.rb
require "cmdx/rspec"

RSpec.configure do |config|
  config.include CMDx::RSpec::Matchers
end
```

Typical flow: stub a collaborator with `allow(...).to execute`, run the subject, then assert on the returned result and on call history with `have_executed`.

```ruby
RSpec.describe ChargeCard do
  it "validates before charging" do
    allow(ValidateCard).to execute(card_id: 1).and_succeed

    result = ChargeCard.execute(card_id: 1)

    expect(result).to be_successful
    expect(result).to have_matching_context(card_id: 1)
    expect(ValidateCard).to have_executed(card_id: 1).once
  end
end
```

- `have_executed` needs a prior `allow(...).to execute` on the same task class (same idea as `have_received`).
- Use `expect(Task).to execute` when the example's main assertion is that the call happened.
- Use `allow(Task).to execute.and_call_original` when the real `work` body should run.

## Core concepts

### What you can assert on

| Kind | Examples | Matcher families |
| --- | --- | --- |
| `CMDx::Result` | Return value of `Task.execute`, or a `build_result` fixture | Outcomes, context, metadata, errors, metrics, chains, tags |
| Task class or instance | `FetchOrder`, `FetchOrder.new(ctx)` | Declarations (`have_input`, `have_callback`, …), `be_deprecated`, `have_tag` |
| `CMDx::Workflow` class | `CheckoutWorkflow` | `have_pipeline_tasks`, `execute_pipeline` |
| Task class (class method) | `FetchOrder.execute(...)` | `execute`, `execute!`, `have_executed`, `have_executed!` |
| Block | `expect { ... }` | `raise_fault`, `have_logs`, `emit_telemetry` |

Result-oriented matchers (outcomes, metadata, metrics, chains, tags on a result) require a `CMDx::Result` or a **deferred** fixture from `build_result` / `execute` outcome chains. They raise `ArgumentError` with `"must be a CMDx::Result"` for other types.

Declaration matchers accept the task **class** or an **instance**. `have_pipeline_tasks` requires a `CMDx::Workflow` class.

### Choosing a result matcher

CMDx splits **state** (`complete` vs `interrupted`) and **status** (`success`, `skipped`, `failed`). Pick the narrowest matcher that matches your example's intent.

| Matcher | Asserts | Good when |
| --- | --- | --- |
| `be_successful` | `state: complete` **and** `status: success` | Default success assertion; optional kwargs match any `result.to_h` field via RSpec `include` |
| `have_skipped` | `state: interrupted` **and** `status: skipped` | Skip path; optional reason / metadata / cause |
| `have_failed` | `state: interrupted` **and** `status: failed` | Failure path; optional reason / cause / metadata |
| `be_ok` | `Result#ok?` (success **or** skipped) | "Did not fail" |
| `be_ko` | `Result#ko?` (skipped **or** failed) | "Not a clean success" — skipped matches **both** `be_ok` and `be_ko` |
| `be_complete` | `state == complete` only | Success without caring about status nuances |
| `be_interrupted` | `state == interrupted` only | Any non-complete state (skip or fail) |

**Useful combinations**

```ruby
expect(result).to be_successful.and have_no_errors
expect(result).to have_skipped(reason: "inactive")
expect(result).to have_failed(cause: be_a(StandardError))
expect(result).to be_interrupted.and(be_ko)          # failed, not skipped
expect(result).to be_successful(metadata: { tier: "pro" })
```

### CMDx built-in predicates vs this gem

The [CMDx testing guide](https://drexed.github.io/cmdx/testing/) documents RSpec predicate matchers on `CMDx::Result` — for example `be_success` → `success?`, `be_failed` → `failed?`, `be_skipped` → `skipped?`.

This gem adds:

- **Pinned state + status** via `result.to_h` (`be_successful`, `have_skipped`, `have_failed`)
- **Declaration** matchers (`have_input`, `have_retry_on`, …)
- **Execution** matchers (`execute`, `have_executed`, workflow pipeline stubs)
- **Diagnostics** block matchers (`have_logs`, `emit_telemetry`, `raise_fault`)

Both styles can coexist in one suite.

For `execute!`, CMDx raises only when the outcome is **failed** (`CMDx::Fault`, or the original exception when `result.cause` is not a fault). Success and skip still return a result in strict mode.

### Deferred result fixtures

`allow(Task).to execute.and_succeed` (and other outcome chains) return a frozen `CMDx::Result` immediately. `build_result.and_succeed` returns a **deferred** fixture that materializes when passed to a matcher or coerced.

Most result matchers call `ResultCoercion.materialize!`, so this works:

```ruby
fixture = build_result.on(FetchOrder).and_output(order_id: 99).and_succeed
expect(fixture).to be_successful
expect(fixture).to have_matching_context(order_id: 99)
```

Call `.build` on a `build_result` chain when you need an explicit `CMDx::Result` (for example `and_return` or manual chain wiring).

## Common patterns

**Stub collaborator, assert subject result and spy**

```ruby
allow(ValidateCard).to execute(card_id: 1).and_succeed
result = ChargeCard.execute(card_id: 1)
expect(result).to be_successful
expect(ValidateCard).to have_executed(card_id: 1).once
```

**Return a crafted result from a stub**

```ruby
allow(FetchSnapshot).to execute.and_return(
  build_result.on(FetchSnapshot).and_output(snapshot: data).and_succeed
)
```

**Strict failure with `execute!`**

```ruby
allow(RiskCheck).to execute!.and_fail(reason: "blocked")
expect { Checkout.execute! }.to raise_fault(Checkout).with_reason("blocked")
```

**Workflow: stub every pipeline step**

```ruby
allow(CheckoutWorkflow).to execute_pipeline.and_succeed
# or per-task outcomes — see [Execution](#execution)
```

**Logs and telemetry in one example**

Each block matcher re-runs the block, so use separate examples or a shared `let` when the action is expensive:

```ruby
expect { MyCommand.execute }.to have_logs.including("status=success")
expect { MyCommand.execute }.to emit_telemetry(:task_executed).on(MyCommand).once
```

**Chain shape after a real run**

```ruby
result = MyWorkflow.execute
expect(result).to have_chain_root(MyWorkflow).and have_chain_size(3)
```

For failure propagation (`origin`, `caused_failure`, `threw_failure`), assert on the result API — see [Result chain analysis](https://drexed.github.io/cmdx/outcomes/result/) in the CMDx docs.

## Matcher catalog

All factory methods live on `CMDx::RSpec::Matchers` after `config.include`. `build_result` is a fixture builder, not a matcher.

| Matcher | Subject | Summary |
| --- | --- | --- |
| `execute` | Task class | Stub or expect `Task.execute` |
| `execute!` | Task class | Stub or expect strict `Task.execute!` |
| `have_executed` | Task class | Spy on `execute` after `allow(...).to execute` |
| `have_executed!` | Task class | Spy on `execute!` |
| `execute_pipeline` | Workflow class | Stub or expect each pipeline task's `execute` |
| `execute_pipeline!` | Workflow class | Strict pipeline variant |
| `be_successful` | `CMDx::Result` | Complete + success; optional `to_h` fields |
| `have_skipped` | `CMDx::Result` | Interrupted + skipped; optional fields |
| `have_failed` | `CMDx::Result` | Interrupted + failed; optional fields |
| `be_ok` | `CMDx::Result` | `ok?` (success or skipped) |
| `be_ko` | `CMDx::Result` | `ko?` (skipped or failed) |
| `be_complete` | `CMDx::Result` | `state == complete` |
| `be_interrupted` | `CMDx::Result` | `state == interrupted` |
| `have_matching_context` | Result, `Context`, or `Hash` | Partial context match (`include`) |
| `have_empty_context` | Result, `Context`, or `Hash` | Empty context |
| `have_matching_metadata` | `CMDx::Result` | Partial metadata match; no args → empty |
| `have_empty_metadata` | `CMDx::Result` | Empty metadata |
| `have_no_errors` | Result, Task, or `Errors` | No validation errors |
| `have_errors_on` | Result, Task, or `Errors` | Errors on a key (+ optional messages) |
| `have_tag` | Task class/instance or Result | Tag on settings or result |
| `have_been_retried` | `CMDx::Result` | Retried at least once, or exact count |
| `have_been_rolled_back` | `CMDx::Result` | Rollback ran |
| `have_duration` | `CMDx::Result` | Duration bounds (ms) |
| `have_chain_root` | `Chain` or Result | Root task class |
| `have_chain_size` | `Chain` or Result | Number of results on chain |
| `be_deprecated` | Task class/instance | Deprecation declaration |
| `have_input` | Task class/instance | Input declaration |
| `have_output` | Task class/instance | Output declaration |
| `have_callback` | Task class/instance | Lifecycle callback |
| `have_middleware` | Task class/instance | Middleware entry |
| `have_retry_on` | Task class/instance | `retry_on` configuration |
| `have_pipeline_tasks` | Workflow class | Pipeline task list |
| `raise_fault` | block | `CMDx::Fault` from `execute!` |
| `have_logs` | block | CMDx logger output |
| `emit_telemetry` | block | Telemetry events (requires `.on(Task)`) |
| `build_result` | — | Fluent real `CMDx::Result` fixture |

Extra keyword arguments on `be_successful`, `have_skipped`, and `have_failed` are forwarded to RSpec's `include` matcher against `result.to_h` (nested matchers such as `be_a(String)` are allowed).

## Matcher reference

### Execution

`execute` and `execute!` are message matchers for class-level `Task.execute` / `execute!`. `allow` stubs; `expect` requires the call. `have_executed` / `have_executed!` assert after the fact (like `have_received`) and require a prior `allow(...).to execute` spy.

Keyword arguments constrain the call **and** seed the result context. A matcher with no arguments matches any call.

`allow(...).not_to` is not supported — use `expect(...).not_to`.

#### Outcome chains (shared by `execute`, `execute!`, and `build_result`)

| Chain | Effect |
| --- | --- |
| `and_succeed(metadata: {})` | Success result |
| `and_skip(reason:, cause:, metadata:)` | Skipped result |
| `and_fail(reason:, cause:, metadata:)` | Failed result |
| `and_throw(upstream_result)` | Echo a **failed** upstream result |
| `with_error(Exception, "msg")` | Failed with cause; derives reason if omitted |
| `and_output(**context)` | Merges into result context (not part of call constraint) |
| `as_deprecated` | Flags deprecated; implies success if no other outcome |

Only one outcome verb per chain; a second conflicting outcome raises `ArgumentError`.

When an outcome is configured, `allow(...).to` returns the frozen `CMDx::Result`. Otherwise it returns the RSpec message expectation.

#### Examples

```ruby
allow(FetchOrder).to execute(account_id: 42).once
expect(FetchOrder).to execute(account_id: 42).once
expect(FetchOrder).not_to execute
expect(FetchOrder).to have_executed(account_id: 42).once

allow(FetchOrder).to execute(account_id: 42).and_succeed
allow(FetchOrder).to execute(account_id: 42).and_skip(reason: "out of stock")
allow(FetchOrder).to execute(account_id: 42).and_fail(reason: "nope")
allow(FetchOrder).to execute!(account_id: 42).and_fail(reason: "nope")

expect(FetchOrder).to execute(account_id: 42).and_succeed.once
allow(FetchOrder).to execute(account_id: 42).and_succeed.and_output(order_id: 99)
allow(FetchOrder).to execute.and_throw(upstream_result)
allow(FetchOrder).to execute.and_fail(reason: "nope").with_error(NoMethodError, "idk where")
allow(FetchOrder).to execute.as_deprecated
```

`and_throw` echoes a failed upstream result. `with_error` sets `cause` and, unless `and_fail` already set a reason, derives one as `"[NoMethodError] idk where"`.

#### Count, order, and implementation

RSpec's count and order chains apply: `.once`, `.twice`, `.exactly(n)`, `.at_least`, `.at_most`, `.times`, `.ordered`.

```ruby
allow(FetchOrder).to execute.and_call_original
allow(FetchOrder).to execute.and_wrap_original do |original, *args, **kwargs, &block|
  original.call(*args, **kwargs, &block)
end
```

`execute` stubs a **class** method. `allow_any_instance_of(Task)` and `expect_any_instance_of(Task)` delegate to the same class-level stub or expectation as `allow(Task)` / `expect(Task)` for workflow instance `#execute` paths. Call-signature keywords apply to class `.execute` only, not instance `#execute`.

#### Workflow stubs

`execute_pipeline` and `execute_pipeline!` apply the same outcome machinery to every distinct task class in the workflow pipeline. By default they target instance `#execute` (how workflows run inner steps). Use `.on_class` when examples call `Task.execute` on pipeline tasks directly.

```ruby
allow(MyWorkflow).to execute_pipeline.and_succeed

allow(MyWorkflow).to(
  execute_pipeline do |task|
    case task
    when TaskB then execute.and_fail(reason: "nope")
    when TaskC then execute.and_skip(reason: "out of stock")
    else execute.and_succeed
    end
  end.and_succeed
)

MyWorkflow.execute
```

### Result outcomes

#### `be_successful`

```ruby
expect(SomeTask.execute).to be_successful
expect(SomeTask.execute).to be_successful(metadata: { id: 1 })
expect(SomeTask.execute).to be_successful(metadata: be_a(Hash))
```

#### `have_skipped`

```ruby
expect(result).to have_skipped
expect(result).to have_skipped(reason: "out of stock", metadata: { code: "NA" })
```

#### `have_failed`

```ruby
expect(result).to have_failed
expect(result).to have_failed(reason: "boom", cause: be_a(NoMethodError))
```

#### `be_ok` / `be_ko`

```ruby
expect(result).to be_ok    # success or skipped
expect(result).to be_ko    # skipped or failed
```

#### `be_complete` / `be_interrupted`

```ruby
expect(result).to be_complete
expect(result).to be_interrupted
```

### Result context, metadata, and errors

#### `have_empty_context` / `have_matching_context`

Accepts a `Hash`, `CMDx::Context`, `CMDx::Result`, or deferred fixture. `have_matching_context` with no keyword args delegates to `have_empty_context`.

```ruby
expect(result).to have_empty_context
expect(result).to have_matching_context(stored_id: 123)
expect(CMDx::Context.new).to have_matching_context(foo: 1)
```

#### `have_empty_metadata` / `have_matching_metadata`

`have_matching_metadata` with no keyword args delegates to `have_empty_metadata`.

```ruby
expect(result).to have_empty_metadata
expect(result).to have_matching_metadata(status_code: 500)
```

#### `have_no_errors` / `have_errors_on`

Accepts `CMDx::Result`, a `CMDx::Task` instance, or `CMDx::Errors`.

```ruby
expect(result).to have_no_errors
expect(result).to have_errors_on(:email)
expect(result).to have_errors_on(:email, "is required")
expect(task).to have_errors_on(:email, "is required", "is invalid")
```

#### `have_tag`

Reads `settings.tags` on a task class/instance, or `result.tags` on a result.

```ruby
expect(SomeTask).to have_tag(:critical)
expect(result).to have_tag(:critical)
```

### Execution metrics

#### `have_been_retried`

```ruby
expect(result).to have_been_retried
expect(result).to have_been_retried(3)
```

#### `have_been_rolled_back`

```ruby
expect(result).to have_been_rolled_back
```

#### `have_duration`

At least one of `:less_than` or `:greater_than` is required (milliseconds).

```ruby
expect(result).to have_duration(less_than: 100)
expect(result).to have_duration(greater_than: 0.1, less_than: 50)
```

Use `build_result.with_duration(ms)` when you need a fixture with a known duration.

### Chains

#### `have_chain_root`

Root task class must match or be a subclass of the expected class. Accepts `CMDx::Chain` or `CMDx::Result`.

```ruby
expect(result).to have_chain_root(MyWorkflow)
expect(result.chain).to have_chain_root(MyWorkflow)
```

#### `have_chain_size`

```ruby
expect(result).to have_chain_size(3)
```

### Task declarations

Matchers introspect task configuration. Pass the **class** or an **instance**.

#### `be_deprecated`

```ruby
expect(SomeTask).to be_deprecated
expect(SomeTask).to be_deprecated.with_warning   # :warn
expect(SomeTask).to be_deprecated.with_logging   # :log
expect(SomeTask).to be_deprecated.with_error     # :error
expect(SomeTask).to be_deprecated.with_behavior(:custom)
```

#### `have_input` / `have_output`

Keyword args are partially matched against the declaration's serialized `to_h`.

```ruby
expect(SomeTask).to have_input(:user_id)
expect(SomeTask).to have_input(:user_id, required: true)
expect(SomeTask).to have_input(:user_id, options: hash_including(coerce: :integer))
expect(SomeTask).to have_output(:total, required: true)
```

#### `have_callback`

Optional `callable` narrows the match (`==` for symbols/lambdas, `is_a?` for classes).

```ruby
expect(SomeTask).to have_callback(:before_execution)
expect(SomeTask).to have_callback(:before_execution, :authenticate!)
expect(SomeTask).to have_callback(:on_failed, AlertOnFailure)
```

#### `have_middleware`

```ruby
expect(SomeTask).to have_middleware(LoggingMiddleware)
```

#### `have_retry_on`

Keyword args match `CMDx::Retry` settings (`:limit`, `:delay`, `:max_delay`, `:jitter`).

```ruby
expect(SomeTask).to have_retry_on(Net::OpenTimeout)
expect(SomeTask).to have_retry_on(Net::OpenTimeout, limit: 5, jitter: :exponential)
```

### Workflows

#### `have_pipeline_tasks`

Order-sensitive by default; `.in_any_order` compares as a set.

```ruby
expect(MyWorkflow).to have_pipeline_tasks(StepA, StepB, StepC)
expect(MyWorkflow).to have_pipeline_tasks(StepA, StepC, StepB).in_any_order
```

### Block matchers

#### `raise_fault`

Asserts a block raises `CMDx::Fault`. Optionally constrain task class, reason, or cause.

```ruby
expect { SomeTask.execute! }.to raise_fault
expect { SomeTask.execute! }.to raise_fault(SomeTask)
expect { SomeTask.execute! }
  .to raise_fault(SomeTask)
  .with_reason(/invalid/)
  .with_cause(MyError)
```

`with_reason` accepts a `String` or `Regexp`. `with_cause` accepts a class (`is_a?`) or a value (`values_match?`).

In application code, `CMDx::Fault.for?`, `Fault.reason?`, and `Fault.matches?` cover `rescue` branches; this matcher is the RSpec equivalent for `execute!`.

#### `have_logs`

Captures `CMDx.configuration.logger` for the block and restores the previous logger. Default: at least one line. Pass a composable matcher or use chains.

```ruby
expect { MyCommand.execute }.to have_logs(include("status=success"))
expect { MyCommand.execute }.to have_logs.including("status=success").once
expect { MyCommand.execute }.to have_logs.matching(/status=\w+/)
expect { MyCommand.execute }.to have_logs(include("a", "b")).on_lines
expect { MyCommand.execute }.to have_logs.with_line_count(2)
```

Count chains: `.once`, `.twice`, `.thrice`, `.exactly(n)`, `.at_least(n)`, `.at_most(n)`.

#### `emit_telemetry`

Subscribes on a task registry for the duration of the block. **`.on(Task)` is required.** With no event filter, all names in `CMDx::Telemetry::EVENTS` are captured. Subclasses of the task passed to `.on` also emit (shared registry until `dup`).

```ruby
expect { MyCommand.execute }.to emit_telemetry(:task_executed).on(MyCommand).once
expect { MyCommand.execute }.to emit_telemetry.on(MyCommand).with_names(:task_started, :task_executed)
expect { MyCommand.execute }.to emit_telemetry(:task_executed).on(MyCommand).with_payload(result: be_a(CMDx::Result))
```

`.with_payload` uses RSpec `include` semantics on each event's `payload`. Count chains apply to the number of captured events.

## Result fixtures (`build_result`)

`build_result` constructs a real `CMDx::Result` without stubbing `execute` — for collaborator return values, chain seeding, or isolated result examples. Outcome chains match `execute` (`and_succeed`, `and_skip`, `and_fail`, `and_throw`, `with_error`, `and_output`, `as_deprecated`).

Keyword arguments on `build_result` seed context (same role as keywords on `execute`).

| Method | Role |
| --- | --- |
| `.on(Task)` | Sets `result.task` |
| `.on_chain(chain)` | Appends onto an existing chain |
| `.with_context(ctx)` | Explicit `CMDx::Context` or hash |
| `.strict(value: true)` | Records `execute!` semantics on the fixture |
| `.as_root(value: true)` | Marks chain root |
| `.with_retries(n)` | Retry count for metrics matchers |
| `.with_duration(ms)` | Duration for `have_duration` |
| `.rolled_back` | Rollback flag |
| `.with_tid(id)` | Execution id |
| `.from_signal(signal)` | Build from a pre-made `CMDx::Signal` |
| `.build` | Materialize explicitly |

```ruby
fixture = build_result(snapshot:).and_succeed
allow(FetchSnapshot).to execute.and_return(fixture)

build_result.and_skip(reason: "not applicable")
build_result.and_fail(reason: "boom", cause: StandardError.new("kaput"))

upstream = build_result.and_fail(reason: "nope")
build_result.and_throw(upstream)

build_result.on(SomeTask).and_output(snapshot:, metadata: { id: 1 }).and_succeed
build_result(snapshot:).strict.and_fail(reason: "nope")
build_result.from_signal(CMDx::Signal.success("done")).and_output(snapshot:)

build_result.and_succeed.as_deprecated.with_retries(2).rolled_back
build_result.on(SomeTask).on_chain(existing_chain).with_context(CMDx::Context.new(foo: 1)).and_succeed
```

## Upgrading from stub helpers

Version 3 replaces `stub_task*` / `expect_task_execution*` / `expected_*` helpers with `execute` message matchers.

| Removed | Use instead |
| --- | --- |
| `stub_task`, `stub_task_success`, `stub_task_skip`, `stub_task_fail`, `stub_task_error`, `stub_task_throw`, `stub_task_deprecated` | `allow(Task).to execute` / `execute!` with outcome chains |
| `stub_task!`, `stub_task_success!`, … | `allow(Task).to execute!` with the same chains |
| `unstub_task`, `unstub_task!` | `allow(Task).to execute.and_call_original` (or `execute!`) |
| `expect_task_execution`, `expect_no_task_execution` (+ `!` variants) | `expect(Task).to execute` / `expect(Task).not_to execute` |
| `expected_task_execution`, `expected_no_task_execution` (+ `!` variants) | `expect(Task).to have_executed` / `expect(Task).not_to have_executed` |
| `build_successful_result`, `build_skipped_result`, … | `build_result(...).and_succeed` / `and_skip` / `and_fail` |
| `capture_cmdx_logs`, `subscribe_telemetry` | `have_logs`, `emit_telemetry` |
| `stub_workflow_tasks` | `allow(MyWorkflow).to execute_pipeline` / `execute_pipeline!` |
| `with_cmdx_chain` | `result.chain` or `emit_telemetry(:task_executed).on(Task)` |

See [CHANGELOG](./CHANGELOG.md) for the full list and release notes.

## Development

Run `bin/setup` to install dependencies, then `rake spec` to run the tests. Use `bin/console` for an interactive prompt.

Release flow: bump `lib/cmdx/rspec/version.rb`, then `bundle exec rake release` to tag, push, and publish to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome at <https://github.com/drexed/cmdx-rspec>. Contributors are expected to follow the [code of conduct](https://github.com/drexed/cmdx-rspec/blob/master/CODE_OF_CONDUCT.md).

## License

Released under the [MIT License](https://opensource.org/licenses/MIT).
