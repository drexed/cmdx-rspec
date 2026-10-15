# frozen_string_literal: true

module CMDx # :nodoc:
  module RSpec
    module Matchers
      # Expects a block to emit telemetry on a Task's registry.
      #
      # Tasks subclassing the Task passed to {.on} also fire (telemetry is cloned
      # at class definition; the registry array is shared by reference until +dup+).
      #
      # @see CMDx::RSpec::Matchers#emit_telemetry
      #
      class EmitTelemetry

        include ::RSpec::Matchers::Composable
        include DelegatesExpectations
        include Support::CountChains

        # @param events [Array<Symbol>] telemetry event names to listen for
        def initialize(events = EMPTY_ARRAY)
          @subscription_events = events
          @command = nil
          @payload = nil
          @expected_names = nil
          @events = []
          initialize_count_chains
        end

        # @return [String]
        def description
          parts = ["emit telemetry"]
          parts << "for #{@subscription_events.map(&:inspect).join(', ')}" if @subscription_events.any?
          parts << "on #{@command}" if @command
          parts << count_chain_description if @count_chain
          parts << "with names #{@expected_names.inspect}" if @expected_names
          parts << "with matching payload" if @payload
          parts.join(" ")
        end

        # @return [Boolean]
        def supports_block_expectations?
          true
        end

        # @param block [#call] block whose side effects are asserted
        # @return [Boolean]
        # @raise [ArgumentError] when +block+ is not callable or {.on} was not called
        def matches?(block)
          raise ArgumentError, "block required" unless block.respond_to?(:call)
          raise ArgumentError, "command must be set with .on(Task)" if @command.nil?

          @events = capture_events(block)
          positive_match?
        end

        # @param block [#call] block whose side effects are asserted
        # @return [Boolean]
        def does_not_match?(block)
          raise ArgumentError, "block required" unless block.respond_to?(:call)
          raise ArgumentError, "command must be set with .on(Task)" if @command.nil?

          @events = capture_events(block)
          !positive_match?
        end

        # @return [String]
        def failure_message
          "expected block to #{description}, but #{failure_detail}"
        end

        # @return [String]
        def failure_message_when_negated
          "expected block not to #{description}, but #{failure_detail}"
        end

        # Task class whose telemetry registry to subscribe to.
        #
        # @param task_class [Class] Task subclass whose registry receives the subscription
        # @return [EmitTelemetry] self
        # @raise [ArgumentError] when +task_class+ is not a Task class
        def on(task_class)
          raise ArgumentError, "command must be a Task class" unless task_class.is_a?(Class) && task_class <= CMDx::Task

          @command = task_class
          self
        end

        # Assert captured events appear in order with these names.
        #
        # @param names [Array<Symbol>] expected telemetry event names
        # @return [EmitTelemetry] self
        def with_names(*names)
          @expected_names = names
          self
        end

        # Assert each captured event's payload includes the given entries.
        #
        # @param data [Hash{Symbol => Object}] expected payload entries (RSpec matchers allowed)
        # @return [EmitTelemetry] self
        def with_payload(**data)
          @payload = data
          self
        end

        private

        def capture_events(block)
          Support::TelemetrySubscription.subscribe(@command, @subscription_events.dup) { block.call }
        end

        def positive_match?
          return false unless count_chain_satisfied?(@events.size)
          return false unless names_satisfied?
          return false unless payload_satisfied?

          true
        end

        def names_satisfied?
          return true if @expected_names.nil?

          @events.map(&:name) == @expected_names
        end

        def payload_satisfied?
          return true if @payload.nil?

          @events.each do |event|
            assert_expectation!(event.payload, built_in_include(**@payload))
          end
          true
        rescue ::RSpec::Expectations::ExpectationNotMetError
          false
        end

        def failure_detail
          if @events.empty?
            "no telemetry events were captured"
          else
            lines = @events.map do |event|
              "  #{event.name}: #{event.payload.inspect}"
            end
            "captured:\n#{lines.join("\n")}"
          end
        end

      end
    end
  end
end
