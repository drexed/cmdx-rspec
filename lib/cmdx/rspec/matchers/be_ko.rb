# frozen_string_literal: true

module CMDx # :nodoc:
  module RSpec
    module Matchers
      # Asserts `result.ko?` — skipped or failed, not success (delegates to the signal).
      #
      # @see CMDx::RSpec::Matchers#be_ko
      #
      class BeKo

        INSTANCE = new

        # @return [String]
        def description
          "have been ko"
        end

        # Coerces deferred fixtures and checks `status` is failed.
        #
        # @param result [CMDx::Result] result under test
        # @return [Boolean]
        # @raise [ArgumentError] when +result+ is not a {CMDx::Result}
        def matches?(result)
          @actual = result
          result = CMDx::RSpec::Support::ResultCoercion.materialize!(result)

          result.ko?
        end

        # @return [String]
        def failure_message
          "expected #{@actual.inspect} to be ko (skipped or failed), but status was #{@actual.status.inspect}"
        end

      end
    end
  end
end
