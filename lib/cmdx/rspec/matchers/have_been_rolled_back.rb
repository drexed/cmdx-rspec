# frozen_string_literal: true

module CMDx # :nodoc:
  module RSpec
    module Matchers
      # Asserts `result.rolled_back?` after CMDx ran rollback for a failure.
      #
      # @see CMDx::RSpec::Matchers#have_been_rolled_back
      #
      class HaveBeenRolledBack

        INSTANCE = new

        # @return [String]
        def description
          "have been rolled back"
        end

        # Coerces deferred fixtures and checks `rolled_back?`.
        #
        # @param result [CMDx::Result] result under test
        # @return [Boolean]
        # @raise [ArgumentError] when +result+ is not a {CMDx::Result}
        def matches?(result)
          @actual = result
          result = CMDx::RSpec::Support::ResultCoercion.materialize!(result)

          result.rolled_back?
        end

        # @return [String]
        def failure_message
          "expected #{@actual.inspect} to have been rolled back, but it wasn't"
        end

        # @return [String]
        def failure_message_when_negated
          "expected #{@actual.inspect} not to have been rolled back, but it was"
        end

      end
    end
  end
end
