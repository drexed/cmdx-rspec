# frozen_string_literal: true

module CMDx
  module RSpec
    module Helpers
      module Mocks

        def expect_execute(command, **context)
          if context.empty?
            expect(command).to receive(:execute).with(no_args)
          else
            expect(command).to receive(:execute).with(**context)
          end
        end

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
