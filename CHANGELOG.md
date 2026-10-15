# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [3.0.0] - Unreleased

### Added
- `build_result` factory — fluent `CMDx::RSpec::Result` with the same outcome chains as `execute` (`and_succeed`, `and_skip`, `and_fail`, `and_throw`, `with_error`, `and_output`, `as_deprecated`) for constructing real `CMDx::Result` fixtures without stubbing execution
- `have_logs` matcher — expect CMDx logger output from a block (`including`, `matching`, `on_lines`, count chains, composable matchers)
- `emit_telemetry` matcher — expect telemetry events from a block (`.on(Task)`, `with_names`, `with_payload`, count chains)
- `execute` and `execute!` matchers — stub or expect task execution. Keyword arguments constrain the call and seed the result context. Outcome chains: `and_succeed`, `and_skip`, `and_fail`, `and_throw`, `and_output`, `with_error`, `as_deprecated`
- `execute_pipeline` and `execute_pipeline!` matchers — stub or expect every pipeline task on a Workflow (instance `#execute` by default; `.on_class` for `Task.execute`)
- `have_executed` and `have_executed!` matchers — assert `execute` / `execute!` after the action, in the style of `have_received`

### Changed
- Performance — reuse frozen `be_empty` and outcome `include` matchers on hot paths; `have_matching_context` with no keys delegates to `have_empty_context` (including deferred fixtures)
- `execute` / `execute!` — support `and_wrap_original` (and other implementation chains with a trailing block on `allow(...).to` / `expect(...).to`), matching RSpec's `receive` matcher
- `execute` / `execute!` — `allow_any_instance_of` and `expect_any_instance_of` stub or expect `Task#execute` on workflow subtask instances (`execute!` maps to `#execute`); call-signature keywords apply to class `.execute` only, not instance `#execute`
- `have_executed` / `have_executed!` — `expect_any_instance_of` asserts instance `#execute` (`have_executed!` expects `strict: true`)
- YARD — standardized `lib/` documentation (intent-first summaries, complete `@param` descriptions, tag order, `@see` links to factories); `:nodoc` on `CMDx` reopenings
- All RSpec matchers are class-based under `CMDx::RSpec::Matchers` (same pattern as `Execute` / `HaveExecuted`). Factory methods on `CMDx::RSpec::Matchers` replace `RSpec::Matchers.define`
- `CMDx::RSpec::Matchers::Execute` and `CMDx::RSpec::Result` share `Support::OutcomeChains` and `Support::ResultFactory`
- README — document execution matchers in place of the stub and mock helpers

### Removed
- `CMDx::RSpec::Helpers` and `build_successful_result`, `build_skipped_result`, `build_failed_result`, and `build_echoed_result` — use `build_result(...).and_succeed` (and the other outcome chains) from `CMDx::RSpec::Matchers`
- `with_cmdx_chain` — use `result.chain` from a returned `CMDx::Result`, or `emit_telemetry(:task_executed).on(Task)` when execution is indirect
- `capture_cmdx_logs` and `subscribe_telemetry` helpers — use `have_logs` and `emit_telemetry` matchers
- `stub_workflow_tasks` — use `allow(MyWorkflow).to execute_pipeline` / `execute_pipeline!` with an outcome chain or per-task block
- `stub_task`, `stub_task!`, `stub_task_success`, `stub_task_success!`, `stub_task_skip`, `stub_task_skip!`, `stub_task_fail`, `stub_task_fail!`, `stub_task_error`, `stub_task_throw`, and `stub_task_deprecated` — use `allow(Task).to execute` / `execute!` with an outcome chain
- `unstub_task` and `unstub_task!` — use `allow(Task).to execute.and_call_original`
- `expect_task_execution`, `expect_task_execution!`, `expect_no_task_execution`, and `expect_no_task_execution!` — use `expect(Task).to execute` / `expect(Task).not_to execute`
- `expected_task_execution`, `expected_task_execution!`, `expected_no_task_execution`, and `expected_no_task_execution!` — use `expect(Task).to have_executed` / `expect(Task).not_to have_executed`

## [2.1.0] - 2026-10-14

### Added
- Added `expected_task_execution`, `expected_task_execution!`, `expected_no_task_execution`, and `expected_no_task_execution!` helpers for asserting on `execute` / `execute!` via `have_received` after the action
- Added `build_result`, `build_successful_result`, `build_skipped_result`, `build_failed_result`, and `build_echoed_result` helpers for constructing real `CMDx::Result` objects without stubbing task execution
- Added `stub_task` and `stub_task!` alias of `stub_task_success` and `stub_task_success!`
- Task stub helpers — raise `ArgumentError` when `command` is not a `CMDx::Task` subclass

### Changed
- README — document RuboCop `RSpec/NoExpectationExample` configuration for task execution mock helpers
- Task execution expectation helpers (`unstub_task`, `expect_task_execution`, `expected_task_execution`, and their `!` variants) — optional positional arguments are forwarded to RSpec's `.with` matcher alongside keyword context
- `build_echoed_result` and `stub_task_throw` — echo upstream validation now raises with message `upstream result must be a failed CMDx::Result`
- `stub_task_fail!` — stubbed `execute!` now raises `CMDx::Fault` (or re-raises `cause`) instead of returning a failed result, matching CMDx strict execution

### Fixed
- Task stub helpers — stubbed results now use the supplied command class for `result.task`

## [2.0.0] - 2026-05-05

### Added
- Support for CMDx v2

### Changes
- Updated helpers and matchers for new internals

## [1.4.0] - 2026-04-09

### Added
- Added `stub_workflow_tasks` helper

## [1.3.0] - 2025-11-09

### Added
- Added context options to unstub and unmock methods

## [1.2.0] - 2025-11-08

### Added
- Added unmock helpers

## [1.1.0] - 2025-11-08

### Added
- Added unstub helpers

## [1.0.0] - 2025-11-08

### Added
- Added mock and stub helpers

### Changed
- Renamed `have_been_success` to `be_successful`
- Renamed `have_been_failure` to `have_failed`
- Renamed `have_been_skipped` to `have_skipped`
- Moved matchers to be within the `lib/rspec/matchers` directory

## [0.2.0] - 2025-09-13

### Added
- Added `have_empty_metadata` and `have_matching_metadata` matchers

### Changed
- Metadata matching must be done via the methods above instead of the fault matchers

## [0.1.0] - 2025-08-24

- Initial release
