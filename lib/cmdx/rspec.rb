# frozen_string_literal: true

module CMDx # :nodoc:
  # RSpec matchers and helpers for testing {CMDx::Task} execution and
  # {CMDx::Result} outcomes without running real `work` bodies.
  #
  # Mix {CMDx::RSpec::Matchers} into example groups (see the README). Requiring
  # this file loads matcher classes, result builders, and factory modules in
  # dependency order.
  module RSpec

    # Frozen empty array reused as a sentinel return value to avoid per-call
    # allocations on hot paths.
    #
    # @api private
    EMPTY_ARRAY = [].freeze
    private_constant :EMPTY_ARRAY

    # Frozen empty hash reused as a sentinel return value to avoid per-call
    # allocations on hot paths.
    #
    # @api private
    EMPTY_HASH = {}.freeze
    private_constant :EMPTY_HASH

    # Shared empty string constant used as a sentinel default. Intentionally
    # not frozen so callers may treat it as a mutable seed when needed.
    #
    # @api private
    EMPTY_STRING = ""
    private_constant :EMPTY_STRING

  end
end

require "cmdx"
require "rspec"

require_relative "rspec/support/outcome_chains"
require_relative "rspec/support/result_coercion"
require_relative "rspec/support/result_deferred"
require_relative "rspec/support/result_factory"
require_relative "rspec/support/result_finisher"
require_relative "rspec/result"

require_relative "rspec/matchers/support/count_chains"
require_relative "rspec/matchers/support/delegates_expectations"
require_relative "rspec/matchers/support/log_capture"
require_relative "rspec/matchers/support/pipeline_tasks"
require_relative "rspec/matchers/support/telemetry_subscription"
require_relative "rspec/matchers/be_complete"
require_relative "rspec/matchers/be_deprecated"
require_relative "rspec/matchers/be_interrupted"
require_relative "rspec/matchers/be_ko"
require_relative "rspec/matchers/be_ok"
require_relative "rspec/matchers/be_successful"
require_relative "rspec/matchers/emit_telemetry"
require_relative "rspec/matchers/execute"
require_relative "rspec/matchers/execute_pipeline"
require_relative "rspec/matchers/have_been_retried"
require_relative "rspec/matchers/have_been_rolled_back"
require_relative "rspec/matchers/have_callback"
require_relative "rspec/matchers/have_chain_root"
require_relative "rspec/matchers/have_chain_size"
require_relative "rspec/matchers/have_duration"
require_relative "rspec/matchers/have_logs"
require_relative "rspec/matchers/have_empty_context"
require_relative "rspec/matchers/have_empty_metadata"
require_relative "rspec/matchers/have_errors_on"
require_relative "rspec/matchers/have_executed"
require_relative "rspec/matchers/have_failed"
require_relative "rspec/matchers/have_input"
require_relative "rspec/matchers/have_matching_context"
require_relative "rspec/matchers/have_matching_metadata"
require_relative "rspec/matchers/have_middleware"
require_relative "rspec/matchers/have_no_errors"
require_relative "rspec/matchers/have_output"
require_relative "rspec/matchers/have_pipeline_tasks"
require_relative "rspec/matchers/have_retry_on"
require_relative "rspec/matchers/have_skipped"
require_relative "rspec/matchers/have_tag"
require_relative "rspec/matchers/raise_fault"
require_relative "rspec/matchers"
