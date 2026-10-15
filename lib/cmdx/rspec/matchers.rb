# frozen_string_literal: true

module CMDx # :nodoc:
  module RSpec
    # Factory methods for RSpec matchers that stub or expect `Task.execute` /
    # `execute!`, assert on {CMDx::Result} outcomes, inspect Task declarations,
    # and validate faults and execution chains.
    #
    # Mix into example groups via `config.include CMDx::RSpec::Matchers`.
    module Matchers

      # Builds a matcher for `Task.execute`.
      #
      # Keyword arguments constrain the call and, when an outcome chain is
      # set, seed the result context. No arguments matches any call.
      #
      # @param args [Array] positional arguments forwarded to `.with`
      # @param kwargs [Hash{Symbol => Object}] keyword arguments forwarded to `.with`
      # @return [Matchers::Execute]
      # @example Stub a successful call
      #   allow(FetchOrder).to execute(account_id: 42).and_succeed
      # @example Require the call
      #   expect(FetchOrder).to execute(account_id: 42).once
      def execute(*args, **kwargs, &block)
        Matchers::Execute.new(:execute, args, kwargs, block)
      end

      # Builds a matcher for `Task.execute!`. A failed outcome raises
      # {CMDx::Fault}, or re-raises `cause` when that cause is not a Fault.
      #
      # @param args [Array] positional arguments forwarded to `.with`
      # @param kwargs [Hash{Symbol => Object}] keyword arguments forwarded to `.with`
      # @return [Matchers::Execute]
      # @example Stub a strict failure
      #   allow(FetchOrder).to execute!(account_id: 42).and_fail(reason: "nope")
      # @see #execute
      def execute!(*args, **kwargs, &block)
        Matchers::Execute.new(:execute!, args, kwargs, block)
      end

      # Builds a matcher that stubs or expects every pipeline task on a Workflow.
      #
      # By default targets `Task#execute` on instances. Use {.on_class} on the
      # returned matcher when examples call `Task.execute` directly. An optional
      # block can return per-task {Matchers::Execute} matchers.
      #
      # @param args [Array] positional arguments forwarded to each task's `.with`
      # @param kwargs [Hash{Symbol => Object}] keyword arguments forwarded to each task's `.with`
      # @yieldparam task [Class] a Task class from the workflow pipeline
      # @yieldreturn [Matchers::Execute, nil] matcher for that task, or nil for the shared config
      # @return [Matchers::ExecutePipeline]
      # @example Stub every pipeline step
      #   allow(MyWorkflow).to execute_pipeline.and_succeed
      # @example Per-task outcomes
      #   allow(MyWorkflow).to execute_pipeline do |task|
      #     task == TaskB ? execute.and_fail(reason: "nope") : execute.and_succeed
      #   end
      def execute_pipeline(*args, **kwargs, &per_task)
        Matchers::ExecutePipeline.new(:execute, args, kwargs, per_task)
      end

      # Strict variant of {#execute_pipeline} for `Task.execute!` / strict instance calls.
      #
      # @param args [Array] positional arguments forwarded to each task's `.with`
      # @param kwargs [Hash{Symbol => Object}] keyword arguments forwarded to each task's `.with`
      # @yieldparam task [Class] a Task class from the workflow pipeline
      # @yieldreturn [Matchers::Execute, nil] matcher for that task, or nil for the shared config
      # @return [Matchers::ExecutePipeline]
      # @see #execute_pipeline
      def execute_pipeline!(*args, **kwargs, &per_task)
        Matchers::ExecutePipeline.new(:execute!, args, kwargs, per_task)
      end

      # Builds a matcher that asserts `Task.execute` was already called.
      # Requires a prior `allow(...).to execute` spy.
      #
      # @param args [Array] positional arguments forwarded to `.with`
      # @param kwargs [Hash{Symbol => Object}] keyword arguments forwarded to `.with`
      # @return [Matchers::HaveExecuted]
      # @example
      #   allow(FetchOrder).to execute
      #   FetchOrder.execute(account_id: 42)
      #   expect(FetchOrder).to have_executed(account_id: 42).once
      def have_executed(*args, **kwargs)
        Matchers::HaveExecuted.new(:execute, args, kwargs)
      end

      # Builds a matcher that asserts `Task.execute!` was already called.
      #
      # @param args [Array] positional arguments forwarded to `.with`
      # @param kwargs [Hash{Symbol => Object}] keyword arguments forwarded to `.with`
      # @return [Matchers::HaveExecuted]
      # @see #have_executed
      def have_executed!(*args, **kwargs)
        Matchers::HaveExecuted.new(:execute!, args, kwargs)
      end

      # Asserts a {CMDx::Result} finished with `state: :complete`.
      #
      # @return [Matchers::BeComplete]
      # @see Matchers::BeComplete
      def be_complete
        Matchers::BeComplete::INSTANCE
      end

      # Asserts a Task class or instance is marked deprecated via CMDx's
      # `deprecation` declaration.
      #
      # @param expected_behavior [Symbol, nil] optional deprecation behavior from the constructor
      # @return [Matchers::BeDeprecated]
      # @example
      #   expect(SomeTask).to be_deprecated.with_warning
      # @see Matchers::BeDeprecated
      def be_deprecated(expected_behavior = nil)
        Matchers::BeDeprecated.new(expected_behavior)
      end

      # Asserts a {CMDx::Result} halted with `state: :interrupted`.
      #
      # @return [Matchers::BeInterrupted]
      # @see Matchers::BeInterrupted
      def be_interrupted
        Matchers::BeInterrupted::INSTANCE
      end

      # Asserts a {CMDx::Result} failed (`status: :failed`).
      #
      # @return [Matchers::BeKo]
      # @see Matchers::BeKo
      def be_ko
        Matchers::BeKo::INSTANCE
      end

      # Asserts a {CMDx::Result} is ok (success or skipped, not failed).
      #
      # @return [Matchers::BeOk]
      # @see Matchers::BeOk
      def be_ok
        Matchers::BeOk::INSTANCE
      end

      # Asserts a {CMDx::Result} succeeded and optionally matches context keys.
      #
      # @param data [Hash{Symbol => Object}] expected context entries (RSpec matchers allowed)
      # @return [Matchers::BeSuccessful]
      # @see Matchers::BeSuccessful
      def be_successful(**data)
        data.empty? ? Matchers::BeSuccessful::INSTANCE : Matchers::BeSuccessful.new(data)
      end

      # Asserts a {CMDx::Result}'s retry count.
      #
      # @param expected_count [Integer, nil] exact retry count when given
      # @return [Matchers::HaveBeenRetried]
      # @see Matchers::HaveBeenRetried
      def have_been_retried(expected_count = nil)
        Matchers::HaveBeenRetried.new(expected_count)
      end

      # Asserts rollback ran for a {CMDx::Result}.
      #
      # @return [Matchers::HaveBeenRolledBack]
      # @see Matchers::HaveBeenRolledBack
      def have_been_rolled_back
        Matchers::HaveBeenRolledBack::INSTANCE
      end

      # Asserts a Task registered a lifecycle callback for +event+.
      #
      # @param event [Symbol] callback event name
      # @param callable [Object, nil] expected callable when narrowing the match
      # @return [Matchers::HaveCallback]
      # @see Matchers::HaveCallback
      def have_callback(event, callable = nil)
        Matchers::HaveCallback.new(event, callable)
      end

      # Asserts a {CMDx::Result}'s chain root is the given Task class.
      #
      # @param task_class [Class] expected root task
      # @return [Matchers::HaveChainRoot]
      # @see Matchers::HaveChainRoot
      def have_chain_root(task_class)
        Matchers::HaveChainRoot.new(task_class)
      end

      # Asserts the number of results on a {CMDx::Result}'s chain.
      #
      # @param expected [Integer] expected chain size
      # @return [Matchers::HaveChainSize]
      # @see Matchers::HaveChainSize
      def have_chain_size(expected)
        Matchers::HaveChainSize.new(expected)
      end

      # Asserts a {CMDx::Result}'s recorded duration falls within bounds (milliseconds).
      #
      # @param less_than [Numeric, nil] exclusive upper bound
      # @param greater_than [Numeric, nil] exclusive lower bound
      # @return [Matchers::HaveDuration]
      # @see Matchers::HaveDuration
      def have_duration(less_than: nil, greater_than: nil)
        Matchers::HaveDuration.new(less_than:, greater_than:)
      end

      # Asserts a {CMDx::Result} has no context data.
      #
      # @return [Matchers::HaveEmptyContext]
      # @see Matchers::HaveEmptyContext
      def have_empty_context
        Matchers::HaveEmptyContext::INSTANCE
      end

      # Asserts a {CMDx::Result} has empty signal metadata.
      #
      # @return [Matchers::HaveEmptyMetadata]
      # @see Matchers::HaveEmptyMetadata
      def have_empty_metadata
        Matchers::HaveEmptyMetadata::INSTANCE
      end

      # Asserts validation errors on a {CMDx::Result} for +key+.
      #
      # @param key [Symbol, String] context key with errors
      # @param messages [Array<String>] expected error messages when given
      # @return [Matchers::HaveErrorsOn]
      # @see Matchers::HaveErrorsOn
      def have_errors_on(key, *messages)
        Matchers::HaveErrorsOn.new(key, messages)
      end

      # Asserts a {CMDx::Result} failed and optionally matches reason, cause, or metadata.
      #
      # @param data [Hash{Symbol => Object}] expected failure attributes (RSpec matchers allowed)
      # @return [Matchers::HaveFailed]
      # @see Matchers::HaveFailed
      def have_failed(**data)
        data.empty? ? Matchers::HaveFailed::INSTANCE : Matchers::HaveFailed.new(data)
      end

      # Asserts a Task's `input` declaration for +name+.
      #
      # @param name [Symbol] input name
      # @param expected [Hash{Symbol => Object}] optional declaration attributes to match
      # @return [Matchers::HaveInput]
      # @example
      #   expect(FetchOrder).to have_input(:account_id, required: true)
      # @see Matchers::HaveInput
      def have_input(name, **expected)
        Matchers::HaveInput.new(name, expected)
      end

      # Asserts a {CMDx::Result}'s context includes the given entries.
      #
      # @param data [Hash{Symbol => Object}] expected context (RSpec matchers allowed)
      # @return [Matchers::HaveMatchingContext]
      # @see Matchers::HaveMatchingContext
      def have_matching_context(**data)
        data.empty? ? Matchers::HaveMatchingContext::INSTANCE : Matchers::HaveMatchingContext.new(data)
      end

      # Asserts a {CMDx::Result}'s metadata includes the given entries.
      #
      # @param data [Hash{Symbol => Object}] expected metadata (RSpec matchers allowed)
      # @return [Matchers::HaveMatchingMetadata]
      # @see Matchers::HaveMatchingMetadata
      def have_matching_metadata(**data)
        data.empty? ? Matchers::HaveMatchingMetadata::INSTANCE : Matchers::HaveMatchingMetadata.new(data)
      end

      # Asserts a Task lists +middleware+ in its middleware stack.
      #
      # @param middleware [Class, Module] expected middleware entry
      # @return [Matchers::HaveMiddleware]
      # @see Matchers::HaveMiddleware
      def have_middleware(middleware)
        Matchers::HaveMiddleware.new(middleware)
      end

      # Asserts a {CMDx::Result} has no validation errors.
      #
      # @return [Matchers::HaveNoErrors]
      # @see Matchers::HaveNoErrors
      def have_no_errors
        Matchers::HaveNoErrors::INSTANCE
      end

      # Asserts a Task's `output` declaration for +name+.
      #
      # @param name [Symbol] output name
      # @param expected [Hash{Symbol => Object}] optional declaration attributes to match
      # @return [Matchers::HaveOutput]
      # @example
      #   expect(FetchOrder).to have_output(:total, required: true)
      # @see Matchers::HaveOutput
      def have_output(name, **expected)
        Matchers::HaveOutput.new(name, expected)
      end

      # Asserts a Workflow's pipeline references the given Task classes.
      #
      # @param expected [Array<Class>] task classes expected in the pipeline
      # @return [Matchers::HavePipelineTasks]
      # @see Matchers::HavePipelineTasks
      def have_pipeline_tasks(*expected)
        Matchers::HavePipelineTasks.new(expected)
      end

      # Asserts a Task's `retry_on` declaration for +exception+.
      #
      # @param exception [Class<Exception>] exception class
      # @param expected [Hash{Symbol => Object}] optional declaration attributes to match
      # @return [Matchers::HaveRetryOn]
      # @example
      #   expect(FetchOrder).to have_retry_on(Net::OpenTimeout, limit: 5)
      # @see Matchers::HaveRetryOn
      def have_retry_on(exception, **expected)
        Matchers::HaveRetryOn.new(exception, expected)
      end

      # Asserts a {CMDx::Result} was skipped and optionally matches reason or metadata.
      #
      # @param data [Hash{Symbol => Object}] expected skip attributes (RSpec matchers allowed)
      # @return [Matchers::HaveSkipped]
      # @see Matchers::HaveSkipped
      def have_skipped(**data)
        data.empty? ? Matchers::HaveSkipped::INSTANCE : Matchers::HaveSkipped.new(data)
      end

      # Asserts a {CMDx::Result} carries +tag+ in its metadata tags list.
      #
      # @param tag [Symbol, String] expected tag
      # @return [Matchers::HaveTag]
      # @see Matchers::HaveTag
      def have_tag(tag)
        Matchers::HaveTag.new(tag)
      end

      # Expects a block to raise {CMDx::Fault}, optionally from a specific Task.
      #
      # @param expected_task [Class, nil] Task class that must appear on the fault
      # @return [Matchers::RaiseFault]
      # @example
      #   expect { FetchOrder.execute! }.to raise_fault(FetchOrder).with_reason("invalid")
      # @see Matchers::RaiseFault
      def raise_fault(expected_task = nil)
        Matchers::RaiseFault.new(expected_task)
      end

      # Expects a block to emit telemetry on a Task's registry.
      #
      # @param events [Array<Symbol>] event names to subscribe to; defaults to all events
      # @return [Matchers::EmitTelemetry]
      # @example
      #   expect { FetchOrder.execute }.to emit_telemetry(:task_executed).on(FetchOrder).once
      # @see Matchers::EmitTelemetry
      def emit_telemetry(*events)
        Matchers::EmitTelemetry.new(events)
      end

      # Expects a block to write matching lines to `CMDx.configuration.logger`.
      #
      # @param expected [Object, nil] composable matcher for joined log text or lines
      # @return [Matchers::HaveLogs]
      # @example
      #   expect { FetchOrder.execute }.to have_logs(include("status=success"))
      # @see Matchers::HaveLogs
      def have_logs(expected = nil)
        Matchers::HaveLogs.new(expected)
      end

      # Starts a {Result} fixture for a real {CMDx::Result} without stubbing
      # `execute`. Outcome chains match {#execute} (`and_succeed`, `and_fail`,
      # `and_throw`, `with_error`, `and_output`, `as_deprecated`). After an
      # outcome chain, returns {Support::ResultDeferred}, which materializes on
      # use — `.build` is optional.
      #
      # @param task [Class, nil] task class for `result.task`
      # @param context [Hash{Symbol => Object}] keys merged into the result context
      # @return [Result, Support::ResultDeferred]
      # @example Collaborator return value
      #   allow(FetchSnapshot).to execute.and_return(
      #     build_result.on(FetchSnapshot).and_output(snapshot:).and_succeed
      #   )
      def build_result(task = nil, **context)
        Result.for(task, **context)
      end

    end
  end
end
