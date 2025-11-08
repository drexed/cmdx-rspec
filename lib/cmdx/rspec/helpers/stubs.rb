# frozen_string_literal: true

module CMDx
  module RSpec
    module Helpers
      # Helper methods for setting up RSpec stubs on CMDx command execution.
      module Stubs

        # Sets up a stub that allows a command to receive :execute and return a successful result.
        #
        # @param command [Class] The command class to stub execution on
        # @param context [Hash] Optional keyword arguments to pass to the command
        #
        # @return [CMDx::Result] The successful result object
        #
        # @example Stubbing successful execution with context
        #   allow_success(MyCommand, user_id: 123, role: "admin")
        #
        #   result = MyCommand.execute(user_id: 123, role: "admin")
        #   expect(result).to have_been_success
        #
        # @example Stubbing successful execution without context
        #   allow_success(MyCommand)
        #
        #   result = MyCommand.execute
        #   expect(result).to have_been_success
        def allow_success(command, **context)
          task   = command.new(context)
          result = task.result

          result.executing!
          result.executed!

          allow(command).to receive(:execute).and_return(result)

          result
        end

        # Sets up a stub that allows a command to receive :execute! and return a successful result.
        #
        # @param command [Class] The command class to stub execution on
        # @param context [Hash] Optional keyword arguments to pass to the command
        #
        # @return [CMDx::Result] The successful result object
        #
        # @example Stubbing successful execution with context
        #   allow_success!(MyCommand, user_id: 123, role: "admin")
        #
        #   result = MyCommand.execute!(user_id: 123, role: "admin")
        #   expect(result).to have_been_success
        #
        # @example Stubbing successful execution without context
        #   allow_success!(MyCommand)
        #
        #   result = MyCommand.execute!
        #   expect(result).to have_been_success
        def allow_success!(command, **context)
          task   = command.new(context)
          result = task.result

          result.executing!
          result.executed!

          allow(command).to receive(:execute!).and_return(result)

          result
        end

        # Sets up a stub that allows a command to receive :execute and return a skipped result.
        #
        # @param command [Class] The command class to stub execution on
        # @param reason [String, nil] Optional reason for skipping
        # @param context [Hash] Optional keyword arguments to pass to the command
        #
        # @return [CMDx::Result] The skipped result object
        #
        # @example Stubbing skipped execution with context
        #   allow_skip(MyCommand, foo: "bar")
        #
        #   result = MyCommand.execute(foo: "bar")
        #   expect(result).to have_been_skipped
        #
        # @example Stubbing skipped execution with reason
        #   allow_skip(MyCommand, reason: "Skipped for testing", foo: "bar")
        #
        #   result = MyCommand.execute(foo: "bar")
        #   expect(result).to have_been_skipped(reason: "Skipped for testing")
        def allow_skip(command, reason: nil, **context)
          task   = command.new(context)
          result = task.result

          result.executing!
          result.skip!(reason, halt: false, cause: CMDx::SkipFault.new(result))

          allow(command).to receive(:execute).and_return(result)

          result
        end

        # Sets up a stub that allows a command to receive :execute! and return a skipped result.
        #
        # @param command [Class] The command class to stub execution on
        # @param reason [String, nil] Optional reason for skipping
        # @param context [Hash] Optional keyword arguments to pass to the command
        #
        # @return [CMDx::Result] The skipped result object
        #
        # @example Stubbing skipped execution with context
        #   allow_skip!(MyCommand, foo: "bar")
        #
        #   result = MyCommand.execute!(foo: "bar")
        #   expect(result).to have_been_skipped
        #
        # @example Stubbing skipped execution with reason
        #   allow_skip!(MyCommand, reason: "Skipped for testing", foo: "bar")
        #
        #   result = MyCommand.execute!(foo: "bar")
        #   expect(result).to have_been_skipped(reason: "Skipped for testing")
        def allow_skip!(command, reason: nil, **context)
          task   = command.new(context)
          result = task.result

          result.executing!
          result.skip!(reason, halt: false, cause: CMDx::SkipFault.new(result))

          allow(command).to receive(:execute!).and_return(result)

          result
        end

        # Sets up a stub that allows a command to receive :execute and return a failed result.
        #
        # @param command [Class] The command class to stub execution on
        # @param reason [String, nil] Optional reason for failure
        # @param context [Hash] Optional keyword arguments to pass to the command
        #
        # @return [CMDx::Result] The failed result object
        #
        # @example Stubbing failed execution with context
        #   allow_failure(MyCommand, foo: "bar")
        #
        #   result = MyCommand.execute(foo: "bar")
        #   expect(result).to have_been_failure
        #
        # @example Stubbing failed execution with reason
        #   allow_failure(MyCommand, reason: "Failed for testing", foo: "bar")
        #
        #   result = MyCommand.execute(foo: "bar")
        #   expect(result).to have_been_failure(reason: "Failed for testing")
        def allow_failure(command, reason: nil, **context)
          task   = command.new(context)
          result = task.result

          result.executing!
          result.fail!(reason, halt: false, cause: CMDx::FailFault.new(result))

          allow(command).to receive(:execute).and_return(result)

          result
        end

        # Sets up a stub that allows a command to receive :execute! and return a failed result.
        #
        # @param command [Class] The command class to stub execution on
        # @param reason [String, nil] Optional reason for failure
        # @param context [Hash] Optional keyword arguments to pass to the command
        #
        # @return [CMDx::Result] The failed result object
        #
        # @example Stubbing failed execution with context
        #   allow_failure!(MyCommand, foo: "bar")
        #
        #   result = MyCommand.execute!(foo: "bar")
        #   expect(result).to have_been_failure
        #
        # @example Stubbing failed execution with reason
        #   allow_failure!(MyCommand, reason: "Failed for testing", foo: "bar")
        #
        #   result = MyCommand.execute!(foo: "bar")
        #   expect(result).to have_been_failure(reason: "Failed for testing")
        def allow_failure!(command, reason: nil, **context)
          task   = command.new(context)
          result = task.result

          result.executing!
          result.fail!(reason, halt: false, cause: CMDx::FailFault.new(result))

          allow(command).to receive(:execute!).and_return(result)

          result
        end

      end
    end
  end
end
