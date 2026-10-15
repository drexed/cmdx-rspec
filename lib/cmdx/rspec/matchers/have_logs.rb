# frozen_string_literal: true

module CMDx # :nodoc:
  module RSpec
    module Matchers
      # Expects a block to write matching lines to `CMDx.configuration.logger`.
      #
      # By default requires at least one log line. Pass a composable matcher to
      # the factory or use chains to narrow the match. Log text is matched against
      # the joined lines unless `.on_lines` is used.
      #
      # @see CMDx::RSpec::Matchers#have_logs
      #
      class HaveLogs

        include ::RSpec::Matchers::Composable
        include DelegatesExpectations
        include Support::CountChains

        # @param expected [Object, nil] composable matcher for joined log text or lines
        def initialize(expected = nil)
          @expected = expected
          @including = nil
          @matching = nil
          @match_on = :joined
          @line_count = nil
          @lines = []
          initialize_count_chains
        end

        # @return [String]
        def description
          parts = ["have CMDx logs"]
          parts << count_chain_description if @count_chain
          parts << "including #{@including.inspect}" if @including
          parts << "matching #{@matching.inspect}" if @matching
          parts << "with #{@line_count} lines" unless @line_count.nil?
          parts << "on lines" if @match_on == :lines
          parts << "matching #{@expected.description}" if @expected.respond_to?(:description)
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

          @lines = Support::LogCapture.capture { block.call }
          positive_match?
        end

        # @param block [#call] block whose side effects are asserted
        # @return [Boolean]
        def does_not_match?(block)
          raise ArgumentError, "block required" unless block.respond_to?(:call)

          @lines = Support::LogCapture.capture { block.call }
          !positive_match?
        end

        # @return [String]
        def failure_message
          base = "expected block to #{description}, but "
          base + failure_detail
        end

        # @return [String]
        def failure_message_when_negated
          "expected block not to #{description}, but #{failure_detail}"
        end

        # Substring or regexp match against joined log text.
        #
        # @param text [String, Regexp] substring or pattern the log output must include
        # @return [HaveLogs] self
        def including(text)
          @including = text
          self
        end

        # Regexp match against joined log text.
        #
        # @param pattern [Regexp] pattern matched against each log line
        # @return [HaveLogs] self
        def matching(pattern)
          @matching = pattern
          self
        end

        # Assert an exact number of log lines (in addition to count chains).
        #
        # @param count [Integer] expected occurrence count
        # @return [HaveLogs] self
        def with_line_count(count)
          @line_count = count
          self
        end

        # Apply the factory matcher to the array of lines instead of joined text.
        #
        # @return [HaveLogs] self
        def on_lines
          @match_on = :lines
          self
        end

        private

        def positive_match?
          return false unless count_chain_satisfied?(@lines.size)
          return false unless @line_count.nil? || @lines.size == @line_count
          return false unless including_satisfied?
          return false unless matching_satisfied?
          return false unless expected_satisfied?

          true
        end

        def including_satisfied?
          return true if @including.nil?

          text = @lines.join
          case @including
          when Regexp then @including.match?(text)
          else text.include?(@including.to_s)
          end
        end

        def matching_satisfied?
          return true if @matching.nil?

          @matching.match?(@lines.join)
        end

        def expected_satisfied?
          return true if @expected.nil?

          actual = @match_on == :lines ? @lines : @lines.join
          values_match?(@expected, actual)
        end

        def failure_detail
          if @lines.empty?
            "nothing was logged"
          else
            "logged:\n#{@lines.map { |line| "  #{line}" }.join("\n")}"
          end
        end

      end
    end
  end
end
