# frozen_string_literal: true

module CMDx # :nodoc:
  module RSpec
    module Matchers
      # Asserts signal metadata includes the supplied keys (RSpec `include` semantics).
      #
      # With no expected keys, delegates to {HaveEmptyMetadata}.
      #
      # @see CMDx::RSpec::Matchers#have_matching_metadata
      #
      class HaveMatchingMetadata

        include DelegatesExpectations

        # @param data [Hash{Symbol => Object}] expected metadata entries
        def initialize(data)
          @data = data
        end

        INSTANCE = new(EMPTY_HASH).freeze

        # @return [String]
        def description
          "have matching metadata"
        end

        # Materializes deferred fixtures and checks metadata with `include` or {HaveEmptyMetadata}.
        #
        # @param result [CMDx::Result] result under test
        # @return [Boolean]
        # @raise [ArgumentError] when +result+ is not a {CMDx::Result}
        # @raise [RSpec::Expectations::ExpectationNotMetError] when metadata does not match
        def matches?(result)
          result = CMDx::RSpec::Support::ResultCoercion.materialize!(result)

          if @data.empty?
            assert_expectation!(result, HaveEmptyMetadata::INSTANCE)
          else
            assert_expectation!(result.to_h[:metadata], built_in_include(**@data))
          end
          true
        end

      end
    end
  end
end
