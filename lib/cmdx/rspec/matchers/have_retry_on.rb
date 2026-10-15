# frozen_string_literal: true

module CMDx # :nodoc:
  module RSpec
    module Matchers
      # Asserts a Task's `retry_on` configuration lists +exception+ and optional settings.
      #
      # @see CMDx::RSpec::Matchers#have_retry_on
      #
      class HaveRetryOn

        # @param exception [Class] exception class from `retry_on`
        # @param expected [Hash{Symbol => Object}] retry configuration values to match
        def initialize(exception, expected)
          @exception = exception
          @expected = expected
        end

        # @return [String]
        def description
          @expected.empty? ? "have retry on #{@exception}" : "have retry on #{@exception} matching #{@expected.inspect}"
        end

        # @param actual [Class, CMDx::Task] task class or instance under test
        # @return [Boolean]
        def matches?(actual)
          @actual = actual
          target = actual.is_a?(Class) ? actual : actual.class
          return false unless target.respond_to?(:retry_on)

          retry_cfg = target.retry_on
          return false unless retry_cfg.exceptions.include?(@exception)
          return true if @expected.empty?

          @expected.all? { |k, v| retry_cfg.public_send(k) == v }
        end

        # @return [String]
        def failure_message
          target = @actual.is_a?(Class) ? @actual : @actual.class
          retry_cfg = target.retry_on
          if retry_cfg.exceptions.none?(@exception)
            "expected #{target} to retry on #{@exception}, but only retries on #{retry_cfg.exceptions.inspect}"
          else
            mismatched = @expected.reject { |k, v| retry_cfg.public_send(k) == v }
            "expected #{target}'s retry_on to match #{@expected.inspect}, but mismatched: #{mismatched.inspect}"
          end
        end

      end
    end
  end
end
