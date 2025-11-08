# frozen_string_literal: true

module CMDx
  module RSpec
    module Helpers
      # Helper methods for setting up RSpec expectations on CMDx command execution.
      module Mocks

        # Sets up an expectation that a command will receive :execute with the given context.
        #
        # @param command [Class] The command class to expect execution on
        # @param context [Hash] Optional keyword arguments to match against
        #
        # @return [RSpec::Mocks::MessageExpectation] The RSpec expectation object
        #
        # @example Expecting execution with context
        #   expect_execute(MyCommand, user_id: 123, role: "admin")
        #
        #   MyCommand.execute(user_id: 123, role: "admin")
        #
        # @example Expecting execution without context
        #   expect_execute(MyCommand)
        #
        #   MyCommand.execute
        def expect_execute(command, **context)
          if context.empty?
            expect(command).to receive(:execute).with(no_args)
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
        #   expect_execute!(MyCommand, user_id: 123, role: "admin")
        #
        #   MyCommand.execute!(user_id: 123, role: "admin")
        #
        # @example Expecting execution without context
        #   expect_execute!(MyCommand)
        #
        #   MyCommand.execute!
        def expect_execute!(command, **context)
          if context.empty?
            expect(command).to receive(:execute!).with(no_args)
          else
            expect(command).to receive(:execute!).with(**context)
          end
        end

      end
    end
  end
end
