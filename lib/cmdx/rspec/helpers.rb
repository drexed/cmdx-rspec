# frozen_string_literal: true

module CMDx
  module RSpec
    # RSpec helpers for stubbing and asserting Task execution. Each helper
    # builds a frozen {CMDx::Result} carrying the requested {CMDx::Signal}
    # and wires it into a fresh {CMDx::Chain} so callers see realistic
    # execution output without invoking the Task's `work`.
    #
    # Mix into example groups via `config.include CMDx::RSpec::Helpers`.
    module Helpers

      # Stubs `command.execute` to return a frozen successful Result.
      #
      # @param command [Class] the Task class to stub
      # @param metadata [Hash] payload exposed via `result.metadata`
      # @param context [Hash{Symbol => Object}] context overrides forwarded to `command.new`
      # @return [CMDx::Result] the frozen Result installed on the stub
      # @example
      #   stub_task_success(SomeTask, metadata: { id: 1 })
      def stub_task_success(command, metadata: {}, **context)
        build_stub(command, :execute, CMDx::Signal.success(nil, metadata:), context)
      end

      # Stubs `command.execute!` (bang variant) to return a frozen successful Result.
      #
      # @param command [Class] the Task class to stub
      # @param metadata [Hash] payload exposed via `result.metadata`
      # @param context [Hash{Symbol => Object}] context overrides forwarded to `command.new`
      # @return [CMDx::Result] the frozen Result installed on the stub
      def stub_task_success!(command, metadata: {}, **context)
        build_stub(command, :execute!, CMDx::Signal.success(nil, metadata:), context, strict: true)
      end

      # Stubs `command.execute` to return a frozen skipped Result.
      #
      # @param command [Class] the Task class to stub
      # @param reason [String, nil] human-readable skip reason
      # @param cause [Exception, nil] originating cause attached to the signal
      # @param metadata [Hash] payload exposed via `result.metadata`
      # @param context [Hash{Symbol => Object}] context overrides forwarded to `command.new`
      # @return [CMDx::Result] the frozen Result installed on the stub
      def stub_task_skip(command, reason: nil, cause: nil, metadata: {}, **context)
        build_stub(command, :execute, CMDx::Signal.skipped(reason, metadata:, cause:), context)
      end

      # Stubs `command.execute!` (bang variant) to return a frozen skipped Result.
      #
      # @param command [Class] the Task class to stub
      # @param reason [String, nil] human-readable skip reason
      # @param cause [Exception, nil] originating cause attached to the signal
      # @param metadata [Hash] payload exposed via `result.metadata`
      # @param context [Hash{Symbol => Object}] context overrides forwarded to `command.new`
      # @return [CMDx::Result] the frozen Result installed on the stub
      def stub_task_skip!(command, reason: nil, cause: nil, metadata: {}, **context)
        build_stub(command, :execute!, CMDx::Signal.skipped(reason, metadata:, cause:), context, strict: true)
      end

      # Stubs `command.execute` to return a frozen failed Result.
      #
      # @param command [Class] the Task class to stub
      # @param reason [String, nil] human-readable failure reason
      # @param cause [Exception, nil] originating cause attached to the signal
      # @param metadata [Hash] payload exposed via `result.metadata`
      # @param context [Hash{Symbol => Object}] context overrides forwarded to `command.new`
      # @return [CMDx::Result] the frozen Result installed on the stub
      def stub_task_fail(command, reason: nil, cause: nil, metadata: {}, **context)
        build_stub(command, :execute, CMDx::Signal.failed(reason, metadata:, cause:), context)
      end

      # Stubs `command.execute!` (bang variant) to return a frozen failed Result.
      #
      # @param command [Class] the Task class to stub
      # @param reason [String, nil] human-readable failure reason
      # @param cause [Exception, nil] originating cause attached to the signal
      # @param metadata [Hash] payload exposed via `result.metadata`
      # @param context [Hash{Symbol => Object}] context overrides forwarded to `command.new`
      # @return [CMDx::Result] the frozen Result installed on the stub
      def stub_task_fail!(command, reason: nil, cause: nil, metadata: {}, **context)
        build_stub(command, :execute!, CMDx::Signal.failed(reason, metadata:, cause:), context, strict: true)
      end

      # Restores `command.execute` to its original implementation.
      # When `context` is supplied, only the matching argument signature is unstubbed.
      #
      # @param command [Class] the Task class to unstub
      # @param context [Hash{Symbol => Object}] argument signature whose stub to release
      # @return [void]
      def unstub_task(command, **context)
        if context.empty?
          allow(command).to receive(:execute).and_call_original
        else
          allow(command).to receive(:execute).with(**context).and_call_original
        end
      end

      # Restores `command.execute!` to its original implementation.
      # When `context` is supplied, only the matching argument signature is unstubbed.
      #
      # @param command [Class] the Task class to unstub
      # @param context [Hash{Symbol => Object}] argument signature whose stub to release
      # @return [void]
      def unstub_task!(command, **context)
        if context.empty?
          allow(command).to receive(:execute!).and_call_original
        else
          allow(command).to receive(:execute!).with(**context).and_call_original
        end
      end

      # Sets a positive message expectation that `command.execute` is invoked.
      # When `context` is supplied, the expectation is constrained to that signature.
      #
      # @param command [Class] the Task class to expect
      # @param context [Hash{Symbol => Object}] argument signature to match
      # @return [RSpec::Mocks::MessageExpectation]
      def expect_task_execution(command, **context)
        if context.empty?
          expect(command).to receive(:execute)
        else
          expect(command).to receive(:execute).with(**context)
        end
      end

      # Sets a positive message expectation that `command.execute!` is invoked.
      # When `context` is supplied, the expectation is constrained to that signature.
      #
      # @param command [Class] the Task class to expect
      # @param context [Hash{Symbol => Object}] argument signature to match
      # @return [RSpec::Mocks::MessageExpectation]
      def expect_task_execution!(command, **context)
        if context.empty?
          expect(command).to receive(:execute!)
        else
          expect(command).to receive(:execute!).with(**context)
        end
      end

      # Sets a negative message expectation that `command.execute` is not invoked.
      # When `context` is supplied, only the matching signature is forbidden.
      #
      # @param command [Class] the Task class to guard
      # @param context [Hash{Symbol => Object}] argument signature to forbid
      # @return [RSpec::Mocks::MessageExpectation]
      def expect_no_task_execution(command, **context)
        if context.empty?
          expect(command).not_to receive(:execute)
        else
          expect(command).not_to receive(:execute).with(**context)
        end
      end

      # Sets a negative message expectation that `command.execute!` is not invoked.
      # When `context` is supplied, only the matching signature is forbidden.
      #
      # @param command [Class] the Task class to guard
      # @param context [Hash{Symbol => Object}] argument signature to forbid
      # @return [RSpec::Mocks::MessageExpectation]
      def expect_no_task_execution!(command, **context)
        if context.empty?
          expect(command).not_to receive(:execute!)
        else
          expect(command).not_to receive(:execute!).with(**context)
        end
      end

      # Yields each distinct Task class reachable from a Workflow's pipeline,
      # in first-seen order, so callers can stub them in a single block.
      #
      # @param command [Class] a Workflow class (must include `CMDx::Workflow`)
      # @yieldparam task [Class] a Task class referenced by the workflow pipeline
      # @return [void]
      # @raise [ArgumentError] when no block is given or `command` is not a Workflow
      # @example
      #   stub_workflow_tasks(MyWorkflow) { |t| stub_task_success(t) }
      def stub_workflow_tasks(command, &)
        if !block_given?
          raise ArgumentError, "block required"
        elsif !command.include?(Workflow)
          raise ArgumentError, "#{command.inspect} must be a workflow"
        end

        command.pipeline.flat_map(&:tasks).uniq.each(&)
      end

      private

      # Constructs a frozen {CMDx::Result} from `signal` and stubs `command.method`
      # to return it. The Result is unshifted onto a new {CMDx::Chain} so callers
      # observe the same shape as a real execution.
      #
      # @api private
      # @param command [Class] the Task class being stubbed
      # @param method [Symbol] the message to stub (`:execute` or `:execute!`)
      # @param signal [CMDx::Signal] outcome payload to wrap
      # @param context [Hash] context overrides for `command.new`
      # @return [CMDx::Result] the frozen Result installed on the stub
      def build_stub(command, method, signal, context, **)
        task   = command.new(context)
        chain  = CMDx::Chain.new
        result = CMDx::Result.new(
          chain,
          task,
          signal,
          root: true,
          id: SecureRandom.uuid_v7,
          **
        )

        chain.unshift(result)

        allow(command).to receive(method).and_return(result)

        result
      end

    end
  end
end
