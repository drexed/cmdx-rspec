# frozen_string_literal: true

module CMDx # :nodoc:
  module RSpec
    module Matchers
      # Asserts `state` / `status` on `result.to_h` match failure, plus optional fields.
      #
      # Extra keyword args use RSpec's `include` matcher (nested matchers allowed).
      #
      # @see CMDx::RSpec::Matchers#have_failed
      #
      class HaveFailed

        include DelegatesExpectations

        # @param data [Hash{Symbol => Object}] extra `result.to_h` fields to `include`
        def initialize(data)
          @data = data
        end

        INSTANCE = new(EMPTY_HASH).freeze

        BASE_INCLUDE = ::RSpec::Matchers::BuiltIn::Include.new(
          state: CMDx::Signal::INTERRUPTED,
          status: CMDx::Signal::FAILED
        )
        private_constant :BASE_INCLUDE

        # @return [String]
        def description
          "have been a failure"
        end

        # Materializes deferred fixtures and delegates to RSpec's `include` matcher on `to_h`.
        #
        # @param result [CMDx::Result] result under test
        # @return [Boolean]
        # @raise [ArgumentError] when +result+ is not a {CMDx::Result}
        # @raise [RSpec::Expectations::ExpectationNotMetError] when attributes do not match
        def matches?(result)
          result = CMDx::RSpec::Support::ResultCoercion.materialize!(result)

          matcher = @data.empty? ? BASE_INCLUDE : built_in_include(state: CMDx::Signal::INTERRUPTED, status: CMDx::Signal::FAILED, **@data)
          assert_expectation!(result.to_h, matcher)
          true
        end

      end
    end
  end
end
