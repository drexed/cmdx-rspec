# frozen_string_literal: true

module CMDx # :nodoc:
  module RSpec
    module Matchers
      # Asserts `result.state` is {CMDx::Signal::COMPLETE} (success finished normally).
      #
      # @see CMDx::RSpec::Matchers#be_complete
      #
      class BeComplete

        INSTANCE = new

        # @return [String]
        def description
          "have completed"
        end

        # Coerces deferred fixtures and compares `state` to {CMDx::Signal::COMPLETE}.
        #
        # @param result [CMDx::Result] result under test
        # @return [Boolean]
        # @raise [ArgumentError] when +result+ is not a {CMDx::Result}
        def matches?(result)
          @actual = result
          result = CMDx::RSpec::Support::ResultCoercion.materialize!(result)

          result.state == CMDx::Signal::COMPLETE
        end

        # @return [String]
        def failure_message
          "expected #{@actual.inspect} to have state #{CMDx::Signal::COMPLETE.inspect}, " \
            "but was #{@actual.state.inspect}"
        end

      end
    end
  end
end
