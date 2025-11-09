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
      #
      # @example Stubbing successful execution without context
      #   stub_task_success(MyCommand)
      #
      #   result = MyCommand.execute
      #   expect(result).to be_successful
      def stub_task_success(command, metadata: {}, **context)
        task   = command.new(context)
        result = task.result

        result.metadata.merge!(metadata)
        result.executing!
        result.executed!

        allow(command).to receive(:execute).and_return(result)

        result
      end

      # Sets up a stub that allows a command to receive :execute! and return a successful result.
      #
      # @param command [Class] The command class to stub execution on
      # @param metadata [Hash] Optional metadata to pass to the result
      # @param context [Hash] Optional keyword arguments to pass to the command
      #
      # @return [CMDx::Result] The successful result object
      #
      # @example Stubbing successful execution with context
      #   stub_task_success!(MyCommand, user_id: 123, role: "admin")
      #
      #   result = MyCommand.execute!(user_id: 123, role: "admin")
      #   expect(result).to be_successful
      #
      # @example Stubbing successful execution without context
      #   stub_task_success!(MyCommand)
      #
      #   result = MyCommand.execute!
      #   expect(result).to be_successful
      def stub_task_success!(command, metadata: {}, **context)
        task   = command.new(context)
        result = task.result

        result.metadata.merge!(metadata)
        result.executing!
        result.executed!

        allow(command).to receive(:execute!).and_return(result)

        result
      end

      # Sets up a stub that allows a command to receive :execute and return a skipped result.
      #
      # @param command [Class] The command class to stub execution on
      # @param reason [String, nil] Optional reason for skipping
      # @param cause [CMDx::Fault, nil] Optional cause for skipping
      # @param metadata [Hash] Optional metadata to pass to the result
      # @param context [Hash] Optional keyword arguments to pass to the command
      #
      # @return [CMDx::Result] The skipped result object
      #
      # @example Stubbing skipped execution with context
      #   stub_task_skip(MyCommand, foo: "bar")
      #
      #   result = MyCommand.execute(foo: "bar")
      #   expect(result).to have_skipped
      #
      # @example Stubbing skipped execution with reason
      #   stub_task_skip(MyCommand, reason: "Skipped for testing", foo: "bar")
      #
      #   result = MyCommand.execute(foo: "bar")
      #   expect(result).to have_skipped(reason: "Skipped for testing")
      def stub_task_skip(command, reason: nil, cause: nil, metadata: {}, **context)
        task   = command.new(context)
        result = task.result
        cause  ||= CMDx::SkipFault.new(result)

        result.executing!
        result.skip!(reason, halt: false, cause:, **metadata)

        allow(command).to receive(:execute).and_return(result)

        result
      end

      # Sets up a stub that allows a command to receive :execute! and return a skipped result.
      #
      # @param command [Class] The command class to stub execution on
      # @param reason [String, nil] Optional reason for skipping
      # @param cause [CMDx::Fault, nil] Optional cause for skipping
      # @param metadata [Hash] Optional metadata to pass to the result
      # @param context [Hash] Optional keyword arguments to pass to the command
      #
      # @return [CMDx::Result] The skipped result object
      #
      # @example Stubbing skipped execution with context
      #   stub_task_skip!(MyCommand, foo: "bar")
      #
      #   result = MyCommand.execute!(foo: "bar")
      #   expect(result).to have_skipped
      #
      # @example Stubbing skipped execution with reason
      #   stub_task_skip!(MyCommand, reason: "Skipped for testing", foo: "bar")
      #
      #   result = MyCommand.execute!(foo: "bar")
      #   expect(result).to have_skipped(reason: "Skipped for testing")
      def stub_task_skip!(command, reason: nil, cause: nil, metadata: {}, **context)
        task   = command.new(context)
        result = task.result
        cause  ||= CMDx::SkipFault.new(result)

        result.executing!
        result.skip!(reason, halt: false, cause:, **metadata)

        allow(command).to receive(:execute!).and_return(result)

        result
      end

      # Sets up a stub that allows a command to receive :execute and return a failed result.
      #
      # @param command [Class] The command class to stub execution on
      # @param reason [String, nil] Optional reason for failure
      # @param cause [CMDx::Fault, nil] Optional cause for failure
      # @param metadata [Hash] Optional metadata to pass to the result
      # @param context [Hash] Optional keyword arguments to pass to the command
      #
      # @return [CMDx::Result] The failed result object
      #
      # @example Stubbing failed execution with context
      #   stub_task_fail(MyCommand, foo: "bar")
      #
      #   result = MyCommand.execute(foo: "bar")
      #   expect(result).to have_failed
      #
      # @example Stubbing failed execution with reason
      #   stub_task_fail(MyCommand, reason: "Failed for testing", foo: "bar")
      #
      #   result = MyCommand.execute(foo: "bar")
      #   expect(result).to have_failed(reason: "Failed for testing")
      def stub_task_fail(command, reason: nil, cause: nil, metadata: {}, **context)
        task   = command.new(context)
        result = task.result
        cause  ||= CMDx::FailFault.new(result)

        result.executing!
        result.fail!(reason, halt: false, cause:, **metadata)

        allow(command).to receive(:execute).and_return(result)

        result
      end

      # Sets up a stub that allows a command to receive :execute! and return a failed result.
      #
      # @param command [Class] The command class to stub execution on
      # @param reason [String, nil] Optional reason for failure
      # @param cause [CMDx::Fault, nil] Optional cause for failure
      # @param metadata [Hash] Optional metadata to pass to the result
      # @param context [Hash] Optional keyword arguments to pass to the command
      #
      # @return [CMDx::Result] The failed result object
      #
      # @example Stubbing failed execution with context
      #   stub_task_fail!(MyCommand, foo: "bar")
      #
      #   result = MyCommand.execute!(foo: "bar")
      #   expect(result).to have_failed
      #
      # @example Stubbing failed execution with reason
      #   stub_task_fail!(MyCommand, reason: "Failed for testing", foo: "bar")
      #
      #   result = MyCommand.execute!(foo: "bar")
      #   expect(result).to have_failed(reason: "Failed for testing")
      def stub_task_fail!(command, reason: nil, cause: nil, metadata: {}, **context)
        task   = command.new(context)
        result = task.result
        cause  ||= CMDx::FailFault.new(result)

        result.executing!
        result.fail!(reason, halt: false, cause:, **metadata)

        allow(command).to receive(:execute!).and_return(result)

        result
      end

      # Unstubs a command's :execute method.
      #
      # @param command [Class] The command class to unstub execution on
      #
      # @return [void]
      #
      # @example Unstubbing execute
      #   unstub_task(MyCommand)
      #
      #   MyCommand.execute
      def unstub_task(command)
        allow(command).to receive(:execute).and_call_original
      end

      # Unstubs a command's :execute! method.
      #
      # @param command [Class] The command class to unstub execution on
      #
      # @return [void]
      #
      # @example Unstubbing execute!
      #   unstub_task!(MyCommand)
      #
      #   MyCommand.execute!
      def unstub_task!(command)
        allow(command).to receive(:execute!).and_call_original
      end

      # Sets up an expectation that a command will receive :execute with the given context.
      #
      # @param command [Class] The command class to expect execution on
      # @param context [Hash] Optional keyword arguments to match against
      #
      # @return [RSpec::Mocks::MessageExpectation] The RSpec expectation object
      #
      # @example Expecting execution with context
      #   expect_task_execution(MyCommand, user_id: 123, role: "admin")
      #
      #   MyCommand.execute(user_id: 123, role: "admin")
      #
      # @example Expecting execution without context
      #   expect_task_execution(MyCommand)
      #
      #   MyCommand.execute
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
      #
      # @example Expecting execution with context
      #   expect_task_execution!(MyCommand, user_id: 123, role: "admin")
      #
      #   MyCommand.execute!(user_id: 123, role: "admin")
      #
      # @example Expecting execution without context
      #   expect_task_execution!(MyCommand)
      #
      #   MyCommand.execute!
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
      #
      # @return [RSpec::Mocks::MessageExpectation] The RSpec expectation object
      #
      # @example Expecting no execution
      #   expect_no_task_execution(MyCommand)
      #
      #   MyCommand.execute
      def expect_no_task_execution(command)
        expect(command).not_to receive(:execute)
      end

      # Sets up an expectation that a command will not receive :execute!.
      #
      # @param command [Class] The command class to expect execution on
      #
      # @return [RSpec::Mocks::MessageExpectation] The RSpec expectation object
      #
      # @example Expecting no execution!
      #   expect_no_task_execution!(MyCommand)
      #
      #   MyCommand.execute!
      def expect_no_task_execution!(command)
        expect(command).not_to receive(:execute!)
      end

    end
  end
end
