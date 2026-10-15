# frozen_string_literal: true

module CMDx # :nodoc:
  module RSpec
    module Matchers
      # Asserts context data includes the supplied keys (RSpec `include` semantics).
      #
      # With no expected keys, delegates to {HaveEmptyContext}.
      #
      # @see CMDx::RSpec::Matchers#have_matching_context
      #
      class HaveMatchingContext

        include DelegatesExpectations

        # @param data [Hash{Symbol => Object}] expected context entries
        def initialize(data)
          @data = data
        end

        INSTANCE = new(EMPTY_HASH).freeze

        # @return [String]
        def description
          "have matching context"
        end

        # Normalizes the subject to a hash and checks entries with `include` or emptiness.
        #
        # @param context [Hash, CMDx::Context, CMDx::Result] context hash, {CMDx::Context}, or result fixture
        # @return [Boolean]
        # @raise [RSpec::Expectations::ExpectationNotMetError] when the context does not match
        def matches?(context)
          if @data.empty?
            assert_expectation!(context, HaveEmptyContext::INSTANCE)
          else
            assert_expectation!(extract_context(context), built_in_include(**@data))
          end
          true
        end

        private

        def extract_context(context)
          case context
          when Hash then context
          when CMDx::Context then context.to_h
          when CMDx::Result then context.context.to_h
          when CMDx::RSpec::Support::ResultDeferred then context.materialize.context.to_h
          else raise "unknown context type #{context.class}"
          end
        end

      end
    end
  end
end
