# frozen_string_literal: true

module CMDx # :nodoc:
  module RSpec
    module Matchers
      module Support
        # Subscribes to a Task's telemetry registry for the duration of a block.
        #
        # @api private
        module TelemetrySubscription

          extend self

          # @param task_class [Class] Task class whose telemetry registry to use
          # @param events [Array<Symbol>] event names to subscribe to;
          #   defaults to all of {CMDx::Telemetry::EVENTS}
          # @yield runs with subscribers attached
          # @return [Array<CMDx::Telemetry::Event>] captured events in emission order
          # @raise [ArgumentError] when no block is given or +task_class+ is invalid
          def subscribe(task_class, events = CMDx::Telemetry::EVENTS, &)
            raise ArgumentError, "block required" unless block_given?
            raise ArgumentError, "command must be a Task class" unless task_class.is_a?(Class) && task_class <= CMDx::Task

            events = CMDx::Telemetry::EVENTS if events.empty?
            captured = []
            telemetry = task_class.telemetry
            listener = ->(event) { captured << event }

            begin
              events.each { |event_name| telemetry.subscribe(event_name, listener) }
              yield
            ensure
              events.each { |event_name| telemetry.unsubscribe(event_name, listener) }
            end

            captured
          end

        end
      end
    end
  end
end
