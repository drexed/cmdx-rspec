# frozen_string_literal: true

module CMDx # :nodoc:
  module RSpec
    module Matchers
      # Asserts context data is empty for a {CMDx::Result}, {CMDx::Context}, or `Hash`.
      #
      # @see CMDx::RSpec::Matchers#have_empty_context
      #
      class HaveEmptyContext

        INSTANCE = new

        include DelegatesExpectations

        # @return [String]
        def description
          "have an empty context"
        end

        # Normalizes the subject to a hash and requires it to be empty.
        #
        # @param context [Hash, CMDx::Context, CMDx::Result] context hash, {CMDx::Context}, or result fixture
        # @return [Boolean]
        # @raise [RSpec::Expectations::ExpectationNotMetError] when the context is not empty
        def matches?(context)
          assert_expectation!(extract_context(context), built_in_empty)
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
