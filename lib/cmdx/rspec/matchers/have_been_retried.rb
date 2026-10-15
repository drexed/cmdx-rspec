# frozen_string_literal: true

module CMDx # :nodoc:
  module RSpec
    module Matchers
      # Asserts `result.retried?` or an exact `result.retries` count.
      #
      # @see CMDx::RSpec::Matchers#have_been_retried
      #
      class HaveBeenRetried

        # @param expected_count [Integer, nil] exact retry count when given
        def initialize(expected_count = nil)
          @expected_count = expected_count
        end

        # @return [String]
        def description
          @expected_count ? "have been retried #{@expected_count} times" : "have been retried"
        end

        # Coerces deferred fixtures and checks `retried?` or an exact `retries` count.
        #
        # @param result [CMDx::Result] result under test
        # @return [Boolean]
        # @raise [ArgumentError] when +result+ is not a {CMDx::Result}
        def matches?(result)
          @actual = result
          result = CMDx::RSpec::Support::ResultCoercion.materialize!(result)

          if @expected_count.nil?
            result.retried?
          else
            result.retries == @expected_count
          end
        end

        # @return [String]
        def failure_message
          if @expected_count
            "expected #{@actual.inspect} to have been retried #{@expected_count} times, but it was #{@actual.retries}"
          else
            "expected #{@actual.inspect} to have been retried, but it wasn't"
          end
        end

        # @return [String]
        def failure_message_when_negated
          if @expected_count
            "expected #{@actual.inspect} not to have been retried #{@expected_count} times, but it was"
          else
            "expected #{@actual.inspect} not to have been retried, but it was retried #{@actual.retries} times"
          end
        end

      end
    end
  end
end
