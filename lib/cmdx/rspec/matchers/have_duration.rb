# frozen_string_literal: true

module CMDx # :nodoc:
  module RSpec
    module Matchers
      # Asserts `result.duration` (milliseconds) satisfies exclusive bounds.
      #
      # At least one of `:less_than` or `:greater_than` is required.
      #
      # @see CMDx::RSpec::Matchers#have_duration
      #
      class HaveDuration

        # Records exclusive duration bounds (at least one is required when matching).
        #
        # @param less_than [Numeric, nil] exclusive upper bound in milliseconds
        # @param greater_than [Numeric, nil] exclusive lower bound in milliseconds
        # @return [void]
        def initialize(less_than: nil, greater_than: nil)
          @less_than = less_than
          @greater_than = greater_than
        end

        # @return [String]
        def description
          parts = []
          parts << "greater than #{@greater_than}ms" if @greater_than
          parts << "less than #{@less_than}ms" if @less_than
          "have duration #{parts.join(' and ')}"
        end

        # Coerces deferred fixtures and checks `duration` against the configured bounds.
        #
        # @param result [CMDx::Result] result under test
        # @return [Boolean]
        # @raise [ArgumentError] when +result+ is not a {CMDx::Result} or bounds are missing
        def matches?(result)
          @actual = result
          result = CMDx::RSpec::Support::ResultCoercion.materialize!(result)
          raise ArgumentError, "provide :less_than and/or :greater_than" if @less_than.nil? && @greater_than.nil?
          return false if result.duration.nil?

          (@less_than.nil? || result.duration < @less_than) &&
            (@greater_than.nil? || result.duration > @greater_than)
        end

        # @return [String]
        def failure_message
          "expected duration to satisfy bounds (less_than: #{@less_than}, greater_than: #{@greater_than}), " \
            "but was #{@actual.duration}"
        end

      end
    end
  end
end
