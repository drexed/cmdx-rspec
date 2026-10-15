# frozen_string_literal: true

module CMDx # :nodoc:
  module RSpec
    module Matchers
      # Asserts `result.ok?` — success or skipped, not failed (delegates to the signal).
      #
      # @see CMDx::RSpec::Matchers#be_ok
      #
      class BeOk

        INSTANCE = new

        # @return [String]
        def description
          "have been ok"
        end

        # Coerces deferred fixtures and checks the result is ok (success or skipped).
        #
        # @param result [CMDx::Result] result under test
        # @return [Boolean]
        # @raise [ArgumentError] when +result+ is not a {CMDx::Result}
        def matches?(result)
          @actual = result
          result = CMDx::RSpec::Support::ResultCoercion.materialize!(result)

          result.ok?
        end

        # @return [String]
        def failure_message
          "expected #{@actual.inspect} to be ok (success or skipped), but status was #{@actual.status.inspect}"
        end

      end
    end
  end
end
