# frozen_string_literal: true

module CMDx
  module RSpec
    module Helpers
      module Stubs

        def allow_success(command, **context)
          task   = command.new(context)
          result = task.result

          result.executing!
          result.executed!

          allow(command).to receive(:execute).and_return(result)

          result
        end

        def allow_success!(command, **context)
          task   = command.new(context)
          result = task.result

          result.executing!
          result.executed!

          allow(command).to receive(:execute!).and_return(result)

          result
        end

        def allow_skip(command, reason: nil, **context)
          task   = command.new(context)
          result = task.result

          result.executing!
          result.skip!(reason, halt: false, cause: CMDx::SkipFault.new(result))

          allow(command).to receive(:execute).and_return(result)

          result
        end

        def allow_skip!(command, reason: nil, **context)
          task   = command.new(context)
          result = task.result

          result.executing!
          result.skip!(reason, halt: false, cause: CMDx::SkipFault.new(result))

          allow(command).to receive(:execute!).and_return(result)

          result
        end

        def allow_failure(command, reason: nil, **context)
          task   = command.new(context)
          result = task.result

          result.executing!
          result.fail!(reason, halt: false, cause: CMDx::FailFault.new(result))

          allow(command).to receive(:execute).and_return(result)

          result
        end

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
