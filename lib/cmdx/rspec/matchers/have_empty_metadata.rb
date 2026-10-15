# frozen_string_literal: true

module CMDx # :nodoc:
  module RSpec
    module Matchers
      # Asserts `result.to_h[:metadata]` is empty.
      #
      # @see CMDx::RSpec::Matchers#have_empty_metadata
      #
      class HaveEmptyMetadata

        INSTANCE = new

        include DelegatesExpectations

        # @return [String]
        def description
          "have an empty metadata"
        end

        # Materializes deferred fixtures and requires `to_h[:metadata]` to be empty.
        #
        # @param result [CMDx::Result] result under test
        # @return [Boolean]
        # @raise [ArgumentError] when +result+ is not a {CMDx::Result}
        # @raise [RSpec::Expectations::ExpectationNotMetError] when metadata is not empty
        def matches?(result)
          result = CMDx::RSpec::Support::ResultCoercion.materialize!(result)

          assert_expectation!(result.to_h[:metadata], built_in_empty)
          true
        end

      end
    end
  end
end
