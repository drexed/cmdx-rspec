# frozen_string_literal: true

module CMDx # :nodoc:
  module RSpec
    module Matchers
      # Message matcher that stubs or expects `Task#execute` on every distinct
      # task class declared in a {CMDx::Workflow} pipeline.
      #
      # Pass it to `allow` or `expect` with a Workflow class. By default each
      # pipeline task is targeted via `allow_any_instance_of` because workflows
      # invoke `task.new(ctx).execute`. Use {.on_class} when examples call
      # `Task.execute` on pipeline tasks directly.
      #
      # Outcome and count chains match {Execute}. A per-task block can return
      # an {Execute} matcher or `nil` to fall back to the shared configuration.
      #
      # @see CMDx::RSpec::Matchers#execute_pipeline
      # @see CMDx::RSpec::Matchers#execute_pipeline!
      #
      class ExecutePipeline

        include ::RSpec::Mocks::Matchers::Matcher

        EXCLUDED_FORWARDS = %i[inspect to_s].freeze
        private_constant :EXCLUDED_FORWARDS

        OUTCOME_METHODS = %i[
          and_succeed and_skip and_fail and_throw and_output as_deprecated with_error
        ].freeze
        private_constant :OUTCOME_METHODS

        COUNT_CHAIN_METHODS = %i[once twice thrice ordered exactly at_least at_most time times].freeze
        private_constant :COUNT_CHAIN_METHODS

        # @param method [Symbol] `:execute` or `:execute!`
        # @param args [Array] positional arguments forwarded to each task's `.with`
        # @param kwargs [Hash{Symbol => Object}] keyword arguments forwarded to each task's `.with`
        # @param per_task [Proc, nil] optional `->(task_class) { execute matcher }`
        def initialize(method, args, kwargs, per_task)
          @method = method
          @per_task = per_task
          @template = Execute.new(method, args, kwargs, nil)
          @target = :instance
        end

        # @return [String] `"execute_pipeline"` or `"execute_pipeline!"`
        def matcher_name
          @method == :execute! ? "execute_pipeline!" : "execute_pipeline"
        end

        # @return [String] prose description of the configured pipeline stub
        def description
          parts = [matcher_name]
          tail = @template.description.sub(/^execute!?\s*/, EMPTY_STRING)
          parts << tail unless tail.empty?
          parts << target_description
          parts.join(" ")
        end

        # Stubs or expects `Task.execute` / `Task.execute!` on pipeline task classes.
        #
        # @return [ExecutePipeline] self
        def on_class
          @target = :class
          self
        end

        # Stubs or expects `Task#execute` on pipeline task instances (default).
        #
        # @return [ExecutePipeline] self
        def on_instances
          @target = :instance
          self
        end

        OUTCOME_METHODS.each do |method_name|
          define_method(method_name) do |*args, **kwargs, &block|
            @template.public_send(method_name, *args, **kwargs, &block)
            self
          end
        end

        COUNT_CHAIN_METHODS.each do |method_name|
          define_method(method_name) do |*args, &block|
            @template.public_send(method_name, *args, &block)
            self
          end
        end

        ::RSpec::Mocks::MessageExpectation.public_instance_methods(false).each do |method_name|
          next if method_defined?(method_name) || EXCLUDED_FORWARDS.include?(method_name)

          define_method(method_name) do |*args, &block|
            @template.public_send(method_name, *args, &block)
            self
          end
          ruby2_keywords(method_name) if respond_to?(:ruby2_keywords, true)
        end

        # @param workflow [Class] workflow class
        # @return [void]
        # @raise [ArgumentError] when +workflow+ is not a Workflow
        def setup_allowance(workflow, &)
          install(workflow, :allow, &)
        end

        # @param workflow [Class] workflow class
        # @return [void]
        # @raise [ArgumentError] when +workflow+ is not a Workflow
        def setup_expectation(workflow, &)
          install(workflow, :expect, &)
        end
        alias matches? setup_expectation

        # @param workflow [Class] workflow class
        # @return [void]
        # @raise [ArgumentError] when +workflow+ is not a Workflow
        def setup_negative_expectation(workflow, &)
          install(workflow, :negate, &)
        end
        alias does_not_match? setup_negative_expectation

        # @return [void]
        # @raise [ArgumentError] pipeline matchers target Workflow classes
        def setup_any_instance_expectation(*)
          raise unsupported_target(:expect_any_instance_of)
        end

        # @return [void]
        # @raise [ArgumentError] pipeline matchers target Workflow classes
        def setup_any_instance_negative_expectation(*)
          raise unsupported_target(:expect_any_instance_of)
        end

        # @return [void]
        # @raise [ArgumentError] pipeline matchers target Workflow classes
        def setup_any_instance_allowance(*)
          raise unsupported_target(:allow_any_instance_of)
        end

        private

        def install(workflow, mode, &)
          ensure_workflow!(workflow)

          Support::PipelineTasks.list(workflow).each do |task|
            matcher = matcher_for(task)
            dispatch(matcher, task, mode, &)
          end

          self
        end

        def matcher_for(task)
          custom = @per_task&.call(task)
          case custom
          when nil then @template.duplicate
          when Execute then custom
          else
            raise ArgumentError, "block must return an `execute` matcher or nil"
          end
        end

        def dispatch(matcher, task, mode, &)
          case [@target, mode]
          in [:instance, :allow]
            matcher.setup_any_instance_allowance(task, &)
          in [:class, :allow]
            matcher.setup_allowance(task, &)
          in [:instance, :expect]
            matcher.setup_any_instance_expectation(task, &)
          in [:class, :expect]
            matcher.setup_expectation(task, &)
          in [:instance, :negate]
            matcher.setup_any_instance_negative_expectation(task, &)
          in [:class, :negate]
            matcher.setup_negative_expectation(task, &)
          end
        end

        def target_description
          @target == :instance ? "on instances" : "on class"
        end

        def ensure_workflow!(workflow)
          return if workflow.is_a?(Class) && workflow.include?(CMDx::Workflow)

          raise ArgumentError, "#{workflow.inspect} must be a workflow"
        end

        def unsupported_target(helper)
          ArgumentError.new(
            "Using #{helper}(...) with `#{matcher_name}` is not supported; " \
            "use allow(MyWorkflow).to #{matcher_name} or expect(MyWorkflow).to #{matcher_name}"
          )
        end

      end
    end
  end
end
