# frozen_string_literal: true

module CMDx # :nodoc:
  module RSpec
    module Matchers
      # Helpers for class matchers that delegate to built-in RSpec matchers.
      #
      # @api private
      module DelegatesExpectations

        RAISE_NOTIFIER = proc { |err, *_args| raise err }
        private_constant :RAISE_NOTIFIER

        BUILT_IN_EMPTY = ::RSpec::Matchers::BuiltIn::BePredicate.new(:be_empty)
        private_constant :BUILT_IN_EMPTY

        # Runs `expect(actual).to matcher`, re-raising {RSpec::Expectations::ExpectationNotMetError}.
        #
        # @param actual [Object] value under test
        # @param matcher [#matches?] built-in or composable RSpec matcher
        # @return [void]
        def assert_expectation!(actual, matcher)
          ::RSpec::Support.with_failure_notifier(RAISE_NOTIFIER) do
            ::RSpec::Expectations::ExpectationTarget.for(actual, nil).to(matcher)
          end
        end

        # @param expected [Hash{Symbol => Object}] entries for RSpec's `include` matcher
        # @return [RSpec::Matchers::BuiltIn::Include]
        def built_in_include(**expected)
          ::RSpec::Matchers::BuiltIn::Include.new(expected)
        end

        # @return [RSpec::Matchers::BuiltIn::BePredicate] `be_empty` predicate matcher
        def built_in_empty
          BUILT_IN_EMPTY
        end

      end
    end
  end
end
