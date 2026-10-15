# frozen_string_literal: true

module CMDx # :nodoc:
  module RSpec
    module Matchers
      # Expects a block to raise {CMDx::Fault}, with optional task, reason, and cause checks.
      #
      # @see CMDx::RSpec::Matchers#raise_fault
      #
      class RaiseFault

        include ::RSpec::Matchers::Composable

        # @param expected_task [Class, nil] task class that must appear on the fault
        def initialize(expected_task = nil)
          @expected_task = expected_task
          @expected_reason = nil
          @expected_cause = nil
          @actual_fault = nil
        end

        # @return [String]
        def description
          parts = ["raise CMDx::Fault"]
          parts << "from #{@expected_task}" if @expected_task
          parts << "with reason #{@expected_reason.inspect}" unless @expected_reason.nil?
          parts << "with cause #{@expected_cause.inspect}" unless @expected_cause.nil?
          parts.join(" ")
        end

        # @return [Boolean]
        def supports_block_expectations?
          true
        end

        # @param block [#call] block whose side effects are asserted
        # @return [Boolean]
        # @raise [ArgumentError] when +block+ is not callable
        def matches?(block)
          raise ArgumentError, "block required" unless block.respond_to?(:call)

          @actual_fault = nil
          begin
            block.call
          rescue CMDx::Fault => e
            @actual_fault = e
          end

          return false if @actual_fault.nil?
          return false if @expected_task && !(@actual_fault.task <= @expected_task) # rubocop:disable Style/InverseMethods
          return false unless @expected_reason.nil? || reason_matches?(@actual_fault.result.reason)
          return false unless @expected_cause.nil? || cause_matches?(@actual_fault.result.cause)

          true
        end

        # @return [String]
        def failure_message
          if @actual_fault.nil?
            "expected block to raise CMDx::Fault, but nothing was raised"
          else
            "expected #{@actual_fault.inspect} (task: #{@actual_fault.task}, reason: " \
              "#{@actual_fault.result.reason.inspect}, cause: #{@actual_fault.result.cause.inspect}) " \
              "to satisfy the matcher"
          end
        end

        # Narrows the match to `fault.result.reason` (equality or regexp).
        #
        # @param reason [String, Regexp] expected fault reason
        # @return [RaiseFault] self
        def with_reason(reason)
          @expected_reason = reason
          self
        end

        # Narrows the match to `fault.result.cause` (class or composable value).
        #
        # @param cause [Class, Object] expected exception class or instance on the fault
        # @return [RaiseFault] self
        def with_cause(cause)
          @expected_cause = cause
          self
        end

        private

        def reason_matches?(actual)
          case @expected_reason
          when Regexp then @expected_reason.match?(actual.to_s)
          else @expected_reason == actual
          end
        end

        def cause_matches?(actual)
          case @expected_cause
          when Class then actual.is_a?(@expected_cause)
          else values_match?(@expected_cause, actual)
          end
        end

      end
    end
  end
end
