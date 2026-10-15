# frozen_string_literal: true

module CMDx # :nodoc:
  module RSpec
    module Matchers
      # Asserts a {CMDx::Workflow}'s flattened pipeline task list matches expectations.
      #
      # @see CMDx::RSpec::Matchers#have_pipeline_tasks
      #
      class HavePipelineTasks

        # @param expected [Array<Class>] expected task classes in pipeline order
        def initialize(expected)
          @expected = expected
          @any_order = false
        end

        # @return [String]
        def description
          "have pipeline tasks #{@expected.inspect}"
        end

        # @param actual [Class] workflow class under test
        # @return [Boolean]
        # @raise [ArgumentError] when +actual+ is not a Workflow class
        def matches?(actual)
          @actual = actual
          raise ArgumentError, "must be a CMDx::Workflow" unless actual.is_a?(Class) && actual.include?(CMDx::Workflow)

          tasks = Support::PipelineTasks.list(actual)
          if @any_order
            tasks.sort_by(&:object_id) == @expected.sort_by(&:object_id)
          else
            tasks == @expected
          end
        end

        # @return [String]
        def failure_message
          "expected #{@actual} pipeline to be #{@expected.inspect}, " \
            "but was #{Support::PipelineTasks.list(@actual).inspect}"
        end

        # Compares task classes without enforcing pipeline order.
        #
        # @return [HavePipelineTasks] self
        def in_any_order
          @any_order = true
          self
        end

      end
    end
  end
end
