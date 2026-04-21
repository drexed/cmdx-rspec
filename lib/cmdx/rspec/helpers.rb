# frozen_string_literal: true

module CMDx
  module RSpec
    # Helper methods for setting up RSpec stubs and expectations on CMDx command execution.
    module Helpers

      # Sets up a stub that allows a command to receive :execute and return a successful result.
      #
      # @param command [Class] The command class to stub execution on
      # @param metadata [Hash] Optional metadata to pass to the result
      # @param context [Hash] Optional keyword arguments to pass to the command
      #
      # @return [CMDx::Result] The successful result object
      #
      # @example Stubbing successful execution with context
      #   stub_task_success(MyCommand, user_id: 123, role: "admin")
      #
      #   result = MyCommand.execute(user_id: 123, role: "admin")
      #   expect(result).to be_successful
      def stub_task_success(command, metadata: {}, **context)
        build_stub(command, :execute, CMDx::Signal.success(nil, metadata:), context)
      end

      # Sets up a stub that allows a command to receive :execute! and return a successful result.
      #
      # @param command [Class] The command class to stub execution on
      # @param metadata [Hash] Optional metadata to pass to the result
      # @param context [Hash] Optional keyword arguments to pass to the command
      #
      # @return [CMDx::Result] The successful result object
      def stub_task_success!(command, metadata: {}, **context)
        build_stub(command, :execute!, CMDx::Signal.success(nil, metadata:), context, strict: true)
      end

      # Sets up a stub that allows a command to receive :execute and return a skipped result.
      #
      # @param command [Class] The command class to stub execution on
      # @param reason [String, nil] Optional reason for skipping
      # @param cause [Exception, nil] Optional underlying exception
      # @param metadata [Hash] Optional metadata to pass to the result
      # @param context [Hash] Optional keyword arguments to pass to the command
      #
      # @return [CMDx::Result] The skipped result object
      def stub_task_skip(command, reason: nil, cause: nil, metadata: {}, **context)
        build_stub(command, :execute, CMDx::Signal.skipped(reason, metadata:, cause:), context)
      end

      # Sets up a stub that allows a command to receive :execute! and return a skipped result.
      #
      # @param command [Class] The command class to stub execution on
      # @param reason [String, nil] Optional reason for skipping
      # @param cause [Exception, nil] Optional underlying exception
      # @param metadata [Hash] Optional metadata to pass to the result
      # @param context [Hash] Optional keyword arguments to pass to the command
      #
      # @return [CMDx::Result] The skipped result object
      def stub_task_skip!(command, reason: nil, cause: nil, metadata: {}, **context)
        build_stub(command, :execute!, CMDx::Signal.skipped(reason, metadata:, cause:), context, strict: true)
      end

      # Sets up a stub that allows a command to receive :execute and return a failed result.
      #
      # @param command [Class] The command class to stub execution on
      # @param reason [String, nil] Optional reason for failure
      # @param cause [Exception, nil] Optional underlying exception
      # @param metadata [Hash] Optional metadata to pass to the result
      # @param context [Hash] Optional keyword arguments to pass to the command
      #
      # @return [CMDx::Result] The failed result object
      def stub_task_fail(command, reason: nil, cause: nil, metadata: {}, **context)
        build_stub(command, :execute, CMDx::Signal.failed(reason, metadata:, cause:), context)
      end

      # Sets up a stub that allows a command to receive :execute! and return a failed result.
      #
      # @param command [Class] The command class to stub execution on
      # @param reason [String, nil] Optional reason for failure
      # @param cause [Exception, nil] Optional underlying exception
      # @param metadata [Hash] Optional metadata to pass to the result
      # @param context [Hash] Optional keyword arguments to pass to the command
      #
      # @return [CMDx::Result] The failed result object
      def stub_task_fail!(command, reason: nil, cause: nil, metadata: {}, **context)
        build_stub(command, :execute!, CMDx::Signal.failed(reason, metadata:, cause:), context, strict: true)
      end

      # Unstubs a command's :execute method.
      #
      # @param command [Class] The command class to unstub execution on
      # @param context [Hash] Optional keyword arguments to match against
      #
      # @return [void]
      def unstub_task(command, **context)
        if context.empty?
          allow(command).to receive(:execute).and_call_original
        else
          allow(command).to receive(:execute).with(**context).and_call_original
        end
      end

      # Unstubs a command's :execute! method.
      #
      # @param command [Class] The command class to unstub execution on
      # @param context [Hash] Optional keyword arguments to match against
      #
      # @return [void]
      def unstub_task!(command, **context)
        if context.empty?
          allow(command).to receive(:execute!).and_call_original
        else
          allow(command).to receive(:execute!).with(**context).and_call_original
        end
      end

      # Sets up an expectation that a command will receive :execute with the given context.
      #
      # @param command [Class] The command class to expect execution on
      # @param context [Hash] Optional keyword arguments to match against
      #
      # @return [RSpec::Mocks::MessageExpectation] The RSpec expectation object
      def expect_task_execution(command, **context)
        if context.empty?
          expect(command).to receive(:execute)
        else
          expect(command).to receive(:execute).with(**context)
        end
      end

      # Sets up an expectation that a command will receive :execute! with the given context.
      #
      # @param command [Class] The command class to expect execution on
      # @param context [Hash] Optional keyword arguments to match against
      #
      # @return [RSpec::Mocks::MessageExpectation] The RSpec expectation object
      def expect_task_execution!(command, **context)
        if context.empty?
          expect(command).to receive(:execute!)
        else
          expect(command).to receive(:execute!).with(**context)
        end
      end

      # Sets up an expectation that a command will not receive :execute.
      #
      # @param command [Class] The command class to expect execution on
      # @param context [Hash] Optional keyword arguments to match against
      #
      # @return [RSpec::Mocks::MessageExpectation] The RSpec expectation object
      def expect_no_task_execution(command, **context)
        if context.empty?
          expect(command).not_to receive(:execute)
        else
          expect(command).not_to receive(:execute).with(**context)
        end
      end

      # Sets up an expectation that a command will not receive :execute!.
      #
      # @param command [Class] The command class to expect execution on
      # @param context [Hash] Optional keyword arguments to match against
      #
      # @return [RSpec::Mocks::MessageExpectation] The RSpec expectation object
      def expect_no_task_execution!(command, **context)
        if context.empty?
          expect(command).not_to receive(:execute!)
        else
          expect(command).not_to receive(:execute!).with(**context)
        end
      end

      # Yields each unique pipeline task class so workflow specs can stub tasks in one place.
      #
      # @param command [Class] Class including {CMDx::Workflow}
      # @yield [Class] Distinct task class per pipeline stage (first-seen order)
      # @return [Array<Class>] Deduplicated task list ({#each} return value)
      # @raise [ArgumentError] if no block is given
      # @raise [ArgumentError] if +command+ does not include {CMDx::Workflow}
      #
      # @example
      #   stub_workflow_tasks(MyWorkflow) do |t|
      #     if t == TaskB
      #       stub_task_success(t)
      #     elsif t == TaskC
      #       stub_task_skip(t)
      #     else
      #       stub_task_success(t)
      #     end
      #   end
      #
      #   MyWorkflow.execute
      def stub_workflow_tasks(command, &)
        if !block_given?
          raise ArgumentError, "block required"
        elsif !command.include?(Workflow)
          raise ArgumentError, "#{command.inspect} must be a workflow"
        end

        command.pipeline.flat_map(&:tasks).uniq.each(&)
      end

      private

      # Fabricates a frozen-style {CMDx::Result} without invoking the
      # Runtime, then stubs +method+ on +command+ to return it.
      #
      # @api private
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
