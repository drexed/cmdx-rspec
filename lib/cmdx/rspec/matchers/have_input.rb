# frozen_string_literal: true

module CMDx # :nodoc:
  module RSpec
    module Matchers
      # Asserts a Task's `inputs` registry defines +name+, optionally matching schema keys.
      #
      # @see CMDx::RSpec::Matchers#have_input
      #
      class HaveInput

        include ::RSpec::Matchers::Composable

        # @param name [Symbol, String] input declaration name
        # @param expected [Hash{Symbol => Object}] partial input schema match
        def initialize(name, expected)
          @name = name
          @expected = expected
        end

        # @return [String]
        def description
          @expected.empty? ? "have input #{@name.inspect}" : "have input #{@name.inspect} matching #{@expected.inspect}"
        end

        # @param actual [Class, CMDx::Task] task class or instance under test
        # @return [Boolean]
        def matches?(actual)
          @actual = actual
          target = actual.is_a?(Class) ? actual : actual.class
          return false unless target.respond_to?(:inputs)

          input = target.inputs.registry[@name.to_sym]
          return false if input.nil?
          return true if @expected.empty?

          schema = input.to_h
          @expected.all? { |k, v| values_match?(v, schema[k]) }
        end

        # @return [String]
        def failure_message
          target = @actual.is_a?(Class) ? @actual : @actual.class
          input = target.inputs.registry[@name.to_sym]
          if input.nil?
            "expected #{target} to declare input #{@name.inspect}, but registry has #{target.inputs.registry.keys.inspect}"
          else
            "expected #{target}'s input #{@name.inspect} to match #{@expected.inspect}, but it was #{input.to_h.inspect}"
          end
        end

      end
    end
  end
end
