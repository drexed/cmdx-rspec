# frozen_string_literal: true

module CMDx # :nodoc:
  module RSpec
    module Matchers
      # Asserts `chain.size` on a {CMDx::Chain} or a result's chain.
      #
      # @see CMDx::RSpec::Matchers#have_chain_size
      #
      class HaveChainSize

        # @param expected [Integer] expected chain size
        def initialize(expected)
          @expected = expected
        end

        # @return [String]
        def description
          "have chain size #{@expected}"
        end

        # @param actual [CMDx::Chain, CMDx::Result] chain or result exposing a chain
        # @return [Boolean]
        def matches?(actual)
          @actual = actual
          chain = extract_chain(actual)
          return false if chain.nil?

          chain.size == @expected
        end

        # @return [String]
        def failure_message
          chain = extract_chain(@actual)
          "expected chain size to be #{@expected}, but was #{chain&.size.inspect}"
        end

        private

        def extract_chain(actual)
          case actual
          when CMDx::Chain  then actual
          when CMDx::Result then actual.chain
          end
        end

      end
    end
  end
end
