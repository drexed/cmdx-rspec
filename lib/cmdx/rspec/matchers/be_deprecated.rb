# frozen_string_literal: true

module CMDx # :nodoc:
  module RSpec
    module Matchers
      # Asserts a Task class (or instance) is marked deprecated via CMDx's
      # `deprecation` declaration, optionally narrowing by behavior (`:warn`, `:log`, `:error`).
      #
      # @see CMDx::RSpec::Matchers#be_deprecated
      #
      class BeDeprecated

        # @param expected_behavior [Symbol, nil] optional deprecation behavior from the constructor
        def initialize(expected_behavior = nil)
          @constructor_behavior = expected_behavior
          @expected_behavior = nil
        end

        # @return [String]
        def description
          if (behavior = resolved_behavior)
            "be deprecated with behavior #{behavior}"
          else
            "be deprecated"
          end
        end

        # @param actual [Class, CMDx::Task] task class or instance under test
        # @return [Boolean]
        def matches?(actual)
          @actual = actual
          target = actual.is_a?(Class) ? actual : actual.class
          deprecation = target.respond_to?(:deprecation) ? target.deprecation : nil
          return false unless deprecation

          behavior = resolved_behavior
          return true unless behavior

          deprecation.instance_variable_get(:@value) == behavior
        end

        # @return [String]
        def failure_message
          if (behavior = resolved_behavior)
            "expected #{@actual} to be deprecated with behavior #{behavior}, but it wasn't"
          else
            "expected #{@actual} to be deprecated, but it wasn't"
          end
        end

        # @return [String]
        def failure_message_when_negated
          if (behavior = resolved_behavior)
            "expected #{@actual} not to be deprecated with behavior #{behavior}, but it was"
          else
            "expected #{@actual} not to be deprecated, but it was"
          end
        end

        # Narrows the match to deprecation behavior `:warn`.
        #
        # @return [BeDeprecated] self
        def with_warning
          @expected_behavior = :warn
          self
        end

        # Narrows the match to deprecation behavior `:log`.
        #
        # @return [BeDeprecated] self
        def with_logging
          @expected_behavior = :log
          self
        end

        # Narrows the match to deprecation behavior `:error`.
        #
        # @return [BeDeprecated] self
        def with_error
          @expected_behavior = :error
          self
        end

        # Narrows the match to an arbitrary deprecation behavior symbol.
        #
        # @param behavior [Symbol] value stored on the deprecation declaration
        # @return [BeDeprecated] self
        def with_behavior(behavior)
          @expected_behavior = behavior
          self
        end

        private

        def resolved_behavior
          @expected_behavior || @constructor_behavior
        end

      end
    end
  end
end
