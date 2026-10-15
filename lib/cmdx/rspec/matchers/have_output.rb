# frozen_string_literal: true

module CMDx # :nodoc:
  module RSpec
    module Matchers
      # Asserts a Task's `outputs` registry defines +name+, optionally matching schema keys.
      #
      # @see CMDx::RSpec::Matchers#have_output
      #
      class HaveOutput

        include ::RSpec::Matchers::Composable

        # @param name [Symbol, String] output declaration name
        # @param expected [Hash{Symbol => Object}] partial output schema match
        def initialize(name, expected)
          @name = name
          @expected = expected
        end

        # @return [String]
        def description
          @expected.empty? ? "have output #{@name.inspect}" : "have output #{@name.inspect} matching #{@expected.inspect}"
        end

        # @param actual [Class, CMDx::Task] task class or instance under test
        # @return [Boolean]
        def matches?(actual)
          @actual = actual
          target = actual.is_a?(Class) ? actual : actual.class
          return false unless target.respond_to?(:outputs)

          output = target.outputs.registry[@name.to_sym]
          return false if output.nil?
          return true if @expected.empty?

          @expected.all? do |k, v|
            value =
              case k
              when :name then output.name
              when :description then output.description
              else output.to_h.fetch(:options, {})[k]
              end
            value = false if k == :required && value.nil?
            values_match?(v, value)
          end
        end

        # @return [String]
        def failure_message
          target = @actual.is_a?(Class) ? @actual : @actual.class
          output = target.outputs.registry[@name.to_sym]
          if output.nil?
            "expected #{target} to declare output #{@name.inspect}, but registry has #{target.outputs.registry.keys.inspect}"
          else
            "expected #{target}'s output #{@name.inspect} to match #{@expected.inspect}, but it was #{output.to_h.inspect}"
          end
        end

      end
    end
  end
end
