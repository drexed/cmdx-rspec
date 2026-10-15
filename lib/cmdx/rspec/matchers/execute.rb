# frozen_string_literal: true

module CMDx # :nodoc:
  module RSpec
    module Matchers
      # Message matcher for `Task.execute` / `Task.execute!`.
      #
      # Pass it to `allow` to stub the call, or to `expect` to require it.
      # Keyword arguments constrain the call and seed the result context.
      # Outcome chains install a frozen {CMDx::Result} instead of running `work`.
      # `execute!` is strict: a failed result raises {CMDx::Fault}, or re-raises
      # `cause` when that cause is not itself a Fault. Success and skip return
      # the result.
      #
      # Includes {RSpec::Mocks::Matchers::Matcher} because `allow` / `expect`
      # only accept matchers tagged with that module. A matcher built with
      # `RSpec::Matchers.define` is rejected.
      #
      # @see CMDx::RSpec::Matchers#execute
      # @see CMDx::RSpec::Matchers#execute!
      # @see CMDx::RSpec::Matchers::HaveExecuted
      #
      # @note After an outcome chain, unknown methods defined on
      #   {RSpec::Mocks::MessageExpectation} (`once`, `and_call_original`,
      #   `and_wrap_original`, `and_return`, …) are recorded and replayed when
      #   the expectation is installed.
      # @note `allow_any_instance_of` / `expect_any_instance_of` stub the
      #   instance `#execute` method (workflows call `task.new(ctx).execute`).
      class Execute

        include ::RSpec::Mocks::Matchers::Matcher
        include CMDx::RSpec::Support::OutcomeChains

        EXCLUDED_FORWARDS = %i[inspect to_s].freeze
        private_constant :EXCLUDED_FORWARDS

        INTERNAL_CALLER = %r{/lib/cmdx/rspec/|/lib/rspec/}
        private_constant :INTERNAL_CALLER

        # @param method [Symbol] `:execute` or `:execute!`
        # @param args [Array] positional arguments forwarded to `.with`
        # @param kwargs [Hash{Symbol => Object}] keyword arguments forwarded to `.with` and stored as context
        # @param block [Proc, nil] implementation used when no outcome chain is set
        def initialize(method, args, kwargs, block)
          @method = method
          @args = args
          @kwargs = kwargs
          @block = block
          @recorded_customizations = []
          initialize_outcome_chains
          @result = nil
          @subject = nil
        end

        # @return [String] `"execute"` or `"execute!"`
        def matcher_name
          @method.to_s
        end

        # @return [String] prose description of the configured call and outcome
        def description
          parts = [matcher_name]
          parts << "with #{arguments_description}" if constrained?
          parts << outcome_description if outcome_description
          parts << "as deprecated" if @deprecated
          parts << count_description if count_description
          parts.join(" ")
        end

        # Copies call constraints, outcomes, and recorded expectation chains.
        #
        # @return [Execute] independent matcher sharing this configuration
        # @api private
        def duplicate
          copy = self.class.new(@method, @args.dup, @kwargs.dup, @block)
          copy.instance_variable_set(:@outcome, @outcome)
          copy.instance_variable_set(:@outcome_options, @outcome_options.dup)
          copy.instance_variable_set(:@output, @output.dup)
          copy.instance_variable_set(:@error, @error)
          copy.instance_variable_set(:@deprecated, @deprecated)
          copy.instance_variable_set(
            :@recorded_customizations,
            @recorded_customizations.map do |playback|
              Playback.new(playback.name, playback.args.dup, playback.instance_variable_get(:@block))
            end
          )
          copy
        end

        # @param subject [Class] task class
        # @return [CMDx::Result, RSpec::Mocks::MessageExpectation] the installed
        #   result when an outcome is configured, otherwise the message expectation
        # @raise [ArgumentError] when +subject+ is not a Task class
        def setup_expectation(subject, &)
          install(subject, :add_message_expectation, &)
        end
        alias matches? setup_expectation

        # @param subject [Class] task class
        # @return [CMDx::Result, RSpec::Mocks::MessageExpectation]
        # @raise [ArgumentError] when +subject+ is not a Task class
        # @note Applies `never` before other customizations, matching `receive`.
        def setup_negative_expectation(subject, &)
          @recorded_customizations.unshift(Playback.new(:never, EMPTY_ARRAY, nil))
          setup_expectation(subject, &)
        end
        alias does_not_match? setup_negative_expectation

        # @param subject [Class] task class
        # @return [CMDx::Result, RSpec::Mocks::MessageExpectation]
        # @raise [ArgumentError] when +subject+ is not a Task class
        def setup_allowance(subject, &)
          install(subject, :add_stub, &)
        end

        # Stubs or expects `Task#execute` on any instance of +subject+.
        #
        # @param subject [Class] task class
        # @return [CMDx::Result, RSpec::Mocks::MessageExpectation]
        # @raise [ArgumentError] when +subject+ is not a Task class
        def setup_any_instance_expectation(subject, &)
          install_any_instance(subject, :add_message_expectation, &)
        end

        # @param subject [Class] task class
        # @return [CMDx::Result, RSpec::Mocks::MessageExpectation]
        # @raise [ArgumentError] when +subject+ is not a Task class
        def setup_any_instance_negative_expectation(subject, &)
          @recorded_customizations.unshift(Playback.new(:never, EMPTY_ARRAY, nil))
          setup_any_instance_expectation(subject, &)
        end

        # @param subject [Class] task class
        # @return [CMDx::Result, RSpec::Mocks::MessageExpectation]
        # @raise [ArgumentError] when +subject+ is not a Task class
        def setup_any_instance_allowance(subject, &)
          install_any_instance(subject, :add_stub, &)
        end

        # Records RSpec count, order, and implementation chains (`once`,
        # `and_call_original`, `and_wrap_original`, `and_return`, ...) and plays
        # them onto the message expectation during setup.
        ::RSpec::Mocks::MessageExpectation.public_instance_methods(false).each do |method_name|
          next if method_defined?(method_name) || EXCLUDED_FORWARDS.include?(method_name)

          define_method(method_name) do |*args, &block|
            @recorded_customizations << Playback.new(method_name, args, block)
            self
          end
          ruby2_keywords(method_name) if respond_to?(:ruby2_keywords, true)
        end

        # Plays a recorded message-expectation chain onto the real expectation.
        #
        # @api private
        class Playback

          # @return [Symbol] message name forwarded to the expectation
          attr_reader :name
          # @return [Array] positional arguments for the forwarded message
          attr_reader :args

          # @param name [Symbol] RSpec message expectation method
          # @param args [Array] arguments for the message
          # @param block [Proc, nil] block for the message
          def initialize(name, args, block)
            @name = name
            @args = args
            @block = block
          end

          # @param target [RSpec::Mocks::MessageExpectation] installed expectation
          # @return [void]
          def playback_onto(target)
            target.__send__(name, *args, &@block)
          end

          # @param value [Proc, nil] block forwarded from `allow(...).to` / `expect(...).to`
          # @return [void]
          def block=(value)
            @block ||= value
          end

        end
        private_constant :Playback

        private

        def install(subject, proxy_method, &setup_block)
          ensure_task!(subject)
          @subject = subject

          proxy = ::RSpec::Mocks.space.proxy_for(subject)
          install_on_proxy(proxy, proxy_method, setup_block)
        end

        def install_any_instance(subject, proxy_method, &setup_block)
          ensure_task!(subject)
          @subject = subject

          proxy = ::RSpec::Mocks.space.any_instance_proxy_for(subject)
          instance_method = @method == :execute! ? :execute : @method
          block = stub_implementation_block(setup_block)
          expectation =
            case proxy_method
            when :add_stub
              proxy.stub(instance_method, &block)
            when :add_message_expectation
              if @recorded_customizations.any? { |playback| playback.name == :never }
                proxy.should_not_receive(instance_method, &block)
              else
                proxy.should_receive(instance_method, &block)
              end
            else
              raise ArgumentError, "unsupported any-instance proxy method #{proxy_method.inspect}"
            end

          # Task context keys constrain class `.execute`, not instance `#execute` (`strict:` only).
          @recorded_customizations.each { |customization| customization.playback_onto(expectation) }

          @result || expectation
        end

        def install_on_proxy(proxy, proxy_method, setup_block)
          block = stub_implementation_block(setup_block)
          expectation = proxy.public_send(proxy_method, @method, { expected_from: user_location }, &block)
          expectation.with(*@args, **@kwargs) if constrained?

          @recorded_customizations.each { |customization| customization.playback_onto(expectation) }

          @result || expectation
        end

        # Matches {RSpec::Mocks::Matchers::Receive} so a block on
        # `allow(...).to execute.and_wrap_original { ... }` is replayed onto the
        # last chain method instead of becoming the stub's inner implementation.
        #
        # @param block [Proc, nil] block from the expectation target's `to` call
        # @return [Proc, nil]
        def move_block_to_last_customization(block)
          last = @recorded_customizations.last
          return block unless last

          last.block = block
          nil
        end

        def stub_implementation_block(setup_block)
          return implementation_block if implementation_block

          setup_block = move_block_to_last_customization(setup_block)
          @block || setup_block
        end

        def implementation_block
          return unless outcome?

          result = assemble_outcome
          @result = result

          if strict? && result.failed?
            proc { |*, **| CMDx::RSpec::Support::ResultFactory.raise_strict_failure!(result) }
          else
            proc { |*, **| result }
          end
        end

        def assemble_outcome
          CMDx::RSpec::Support::ResultFactory.assemble_from_outcome(
            self,
            task: @subject,
            context: outcome_context,
            strict: strict?,
            deprecated: @deprecated
          )
        end

        def strict?
          @method == :execute!
        end

        def constrained?
          @args.any? || @kwargs.any?
        end

        def ensure_task!(subject)
          return if subject.is_a?(Class) && subject <= CMDx::Task

          raise ArgumentError, "command must be a Task class"
        end

        def user_location
          caller.each do |frame|
            return frame unless frame =~ INTERNAL_CALLER || frame.start_with?("<internal:")
          end

          caller(1, 1).first
        end

        def outcome_context
          return @kwargs if @output.empty?
          return @output if @kwargs.empty?

          @kwargs.merge(@output)
        end

        def arguments_description
          if @args.empty?
            @kwargs.inspect
          elsif @kwargs.empty?
            @args.map(&:inspect).join(", ")
          else
            [@args.map(&:inspect).join(", "), @kwargs.inspect].join(" ")
          end
        end

        def outcome_description
          return unless resolved_outcome

          phrase = "and #{outcome_verb}"
          phrase << " with reason #{@outcome_options[:reason].inspect}" if @outcome_options[:reason]
          phrase << error_suffix
          phrase << " with output #{@output.inspect}" unless @output.empty?
          phrase
        end

        def outcome_verb
          CMDx::RSpec::Support::OutcomeChains::OUTCOME_VERBS[resolved_outcome]
        end

        def error_suffix
          return EMPTY_STRING unless @error

          exception, message = @error
          if exception.is_a?(Class)
            label = exception.name
            detail = message
          else
            label = exception.class.name
            detail = message || exception.message
          end

          detail ? " with error #{label} #{detail.inspect}" : " with error #{label}"
        end

        def count_description
          @recorded_customizations.each do |customization|
            phrase =
              case customization.name
              when :once then "once"
              when :twice then "twice"
              when :thrice then "thrice"
              when :exactly then "exactly #{customization.args.first} times"
              when :at_least then "at least #{customization.args.first} times"
              when :at_most then "at most #{customization.args.first} times"
              end
            return phrase if phrase
          end

          nil
        end

      end
    end
  end
end
