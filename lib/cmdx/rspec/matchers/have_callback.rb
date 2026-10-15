# frozen_string_literal: true

module CMDx # :nodoc:
  module RSpec
    module Matchers
      # Asserts a Task registers a callback for +event+ on its callback registry.
      #
      # @see CMDx::RSpec::Matchers#have_callback
      #
      class HaveCallback

        # @param event [Symbol] callback event name
        # @param callable [Object, nil] expected callable when narrowing the match
        def initialize(event, callable = nil)
          @event = event
          @callable = callable
        end

        # @return [String]
        def description
          @callable.nil? ? "have callback for #{@event.inspect}" : "have callback #{@callable.inspect} for #{@event.inspect}"
        end

        # @param actual [Class, CMDx::Task] task class or instance under test
        # @return [Boolean]
        def matches?(actual)
          @actual = actual
          target = actual.is_a?(Class) ? actual : actual.class
          return false unless target.respond_to?(:callbacks)

          entries = target.callbacks.registry[@event]
          return false if entries.nil? || entries.empty?
          return true if @callable.nil?

          entries.any? do |cb, _opts|
            case @callable
            when Class then cb.is_a?(@callable)
            else cb == @callable
            end
          end
        end

        # @return [String]
        def failure_message
          target = @actual.is_a?(Class) ? @actual : @actual.class
          entries = target.callbacks.registry[@event] || EMPTY_ARRAY
          if entries.empty?
            "expected #{target} to register a callback for #{@event.inspect}, but none were registered"
          else
            "expected #{target} to register #{@callable.inspect} for #{@event.inspect}, but had #{entries.map(&:first).inspect}"
          end
        end

      end
    end
  end
end
