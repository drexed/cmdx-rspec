# frozen_string_literal: true

module CMDx # :nodoc:
  module RSpec
    module Matchers
      # Asserts that `Task.execute` or `Task.execute!` was already called.
      #
      # Requires a prior spy, such as `allow(Task).to execute` or
      # `allow(Task).to execute.and_call_original`. Keyword arguments constrain
      # the recorded call the same way `have_received(...).with` does.
      # Failure messages come from that matcher so argument and count diffs
      # stay RSpec's.
      #
      # `expect_any_instance_of(Task)` asserts `Task#execute` on instances
      # (workflows call `task.new(ctx).execute`). `have_executed!` maps to
      # `#execute` with `strict: true`.
      #
      # @see CMDx::RSpec::Matchers#have_executed
      # @see CMDx::RSpec::Matchers#have_executed!
      # @see CMDx::RSpec::Matchers::Execute
      class HaveExecuted

        include ::RSpec::Mocks::Matchers::Matcher

        COUNT_CHAIN_NAMES = %i[once twice thrice exactly at_least at_most time times].freeze
        private_constant :COUNT_CHAIN_NAMES

        # @param method [Symbol] `:execute` or `:execute!`
        # @param args [Array] positional arguments forwarded to `.with`
        # @param kwargs [Hash{Symbol => Object}] keyword arguments forwarded to `.with`
        def initialize(method, args, kwargs)
          @method = method
          @args = args
          @kwargs = kwargs
          @chains = []
          @inner = nil
          @any_instance = false
        end

        # @return [String] `"have_executed"` or `"have_executed!"`
        def matcher_name
          @method == :execute! ? "have_executed!" : "have_executed"
        end

        # @return [String] prose description of the expected call
        def description
          parts = [@method == :execute! ? "have executed!" : "have executed"]
          parts << "with #{arguments_description}" if constrained?
          parts << count_description if count_description
          parts.join(" ")
        end

        # Replaces the `.with` constraint on the underlying `have_received` matcher.
        #
        # @param args [Array] positional arguments forwarded to `.with`
        # @param kwargs [Hash{Symbol => Object}] keyword arguments forwarded to `.with`
        # @return [HaveExecuted] self
        def with(*args, **kwargs)
          @args = args
          @kwargs = kwargs
          self
        end

        # @!group Call count and order
        # Matchers in this group forward to RSpec's `have_received` chains.

        # @!method once()
        #   @return [HaveExecuted] self
        # @!method twice()
        #   @return [HaveExecuted] self
        # @!method thrice()
        #   @return [HaveExecuted] self
        # @!method ordered()
        #   @return [HaveExecuted] self
        # @!method exactly(count)
        #   @param count [Integer]
        #   @return [HaveExecuted] self
        # @!method at_least(count)
        #   @param count [Integer]
        #   @return [HaveExecuted] self
        # @!method at_most(count)
        #   @param count [Integer]
        #   @return [HaveExecuted] self
        # @!method time(count)
        #   @param count [Integer]
        #   @return [HaveExecuted] self
        # @!method times(count)
        #   @param count [Integer]
        #   @return [HaveExecuted] self
        # @!endgroup

        %i[once twice thrice ordered].each do |name|
          define_method(name) do |&block|
            @chains << [name, EMPTY_ARRAY, block]
            self
          end
        end

        %i[exactly at_least at_most time times].each do |name|
          define_method(name) do |*args, &block|
            @chains << [name, args, block]
            self
          end
        end

        # @param subject [Class] task class
        # @return [Boolean]
        # @raise [ArgumentError] when +subject+ is not a Task class
        # @raise [RSpec::Mocks::MockExpectationError] when +method+ was not stubbed
        def matches?(subject, &)
          ensure_task!(subject)
          return match_any_instance(subject, negative: false, &) if @any_instance

          @inner = build_inner
          @inner.matches?(subject, &)
        end

        # @param subject [Class] task class
        # @return [Boolean]
        # @raise [ArgumentError] when +subject+ is not a Task class
        # @raise [RSpec::Mocks::MockExpectationError] when a count chain is combined with negation
        def does_not_match?(subject, &)
          ensure_task!(subject)
          return match_any_instance(subject, negative: true, &) if @any_instance

          @inner = build_inner
          @inner.does_not_match?(subject, &)
        end

        # @return [String] RSpec's `have_received` failure message
        def failure_message
          @inner&.failure_message || "expected #{description}"
        end

        # @return [String] RSpec's negated `have_received` failure message
        def failure_message_when_negated
          @inner&.failure_message_when_negated || "expected not to #{description}"
        end

        # @param subject [Class] task class under test
        # @return [void]
        # @raise [RSpec::Expectations::ExpectationNotMetError] when the call was not recorded
        def setup_expectation(subject, &)
          return if matches?(subject, &)

          raise ::RSpec::Expectations::ExpectationNotMetError, failure_message
        end

        # @param subject [Class] task class under test
        # @return [void]
        # @raise [RSpec::Expectations::ExpectationNotMetError] when the call was recorded
        def setup_negative_expectation(subject, &)
          return if does_not_match?(subject, &)

          raise ::RSpec::Expectations::ExpectationNotMetError, failure_message_when_negated
        end

        # @return [void]
        # @raise [ArgumentError] `allow` has nothing to record after the fact
        def setup_allowance(*)
          raise ArgumentError, "Using allow(...) with the `#{matcher_name}` matcher is not supported as it would have no effect"
        end

        # @param subject [Class] task class
        # @return [void]
        def setup_any_instance_expectation(subject, &)
          @any_instance = true
          setup_expectation(subject, &)
        end

        # @param subject [Class] task class
        # @return [void]
        def setup_any_instance_negative_expectation(subject, &)
          @any_instance = true
          setup_negative_expectation(subject, &)
        end

        # @raise [ArgumentError] `have_executed` cannot target instances
        def setup_any_instance_allowance(*)
          raise ArgumentError, "Using allow_any_instance_of(...) with the `#{matcher_name}` matcher is not supported"
        end

        private

        def build_inner(any_instance: @any_instance)
          method_name = any_instance ? instance_execute_method : @method
          inner = ::RSpec::Mocks::Matchers::HaveReceived.new(method_name)

          if any_instance
            if @method == :execute! && !constrained?
              inner.with(strict: true)
            elsif constrained?
              inner.with(*@args, **@kwargs)
            end
          elsif constrained?
            inner.with(*@args, **@kwargs)
          end

          @chains.each do |name, args, chain_block|
            inner.public_send(name, *args, &chain_block)
          end
          inner
        end

        def match_any_instance(klass, negative:, &)
          ensure_any_instance_spy!(klass)

          if ordered?
            proxy = first_instance_proxy(klass)
            @inner = build_inner(any_instance: true)
            return proxy ? @inner.does_not_match?(proxy.object) : negative if negative

            return proxy ? @inner.matches?(proxy.object, &) : false
          end

          if negative
            ensure_count_unconstrained_for_negation!
            proxies = instance_proxies(klass)
            if proxies.empty?
              @inner = build_inner(any_instance: true)
              return true
            end

            success = proxies.all? { |proxy| build_inner(any_instance: true).does_not_match?(proxy.object) }
            @inner = build_inner(any_instance: true)
            @inner.does_not_match?(proxies.first.object) unless success
            return success
          end

          total = total_invocations(klass, &)
          success = invocation_count_satisfied?(total)
          unless success
            proxy = first_instance_proxy(klass)
            @inner = build_inner(any_instance: true)
            @inner.matches?(proxy.object, &) if proxy
          end
          success
        end

        def total_invocations(klass, &block)
          instance_proxies(klass).sum { |proxy| count_matching_on_proxy(proxy, &block) }
        end

        def count_matching_on_proxy(proxy, &)
          expectation = proxy.build_expectation(instance_execute_method)
          apply_instance_constraints!(expectation)

          proxy.replay_received_message_on(expectation, &)
          expectation.instance_variable_get(:@actual_received_count)
        rescue ::RSpec::Mocks::MockExpectationError
          0
        end

        def apply_instance_constraints!(expectation)
          if @method == :execute! && !constrained?
            expectation.with(strict: true)
          elsif constrained?
            expectation.with(*@args, **@kwargs)
          end
        end

        def invocation_count_satisfied?(total)
          spec = count_spec
          return total >= 1 unless spec

          case spec.first
          when :exactly then total == spec.last
          when :at_least then total >= spec.last
          when :at_most then total <= spec.last
          else
            false
          end
        end

        def count_spec
          @chains.each do |name, args, _block|
            case name
            when :once then return [:exactly, 1]
            when :twice then return [:exactly, 2]
            when :thrice then return [:exactly, 3]
            when :exactly, :time, :times then return [:exactly, args.first]
            when :at_least then return [:at_least, args.first]
            when :at_most then return [:at_most, args.first]
            end
          end
          nil
        end

        def count_constrained?
          !count_spec.nil?
        end

        def ordered?
          @chains.any? { |name, *_| name == :ordered }
        end

        def ensure_count_unconstrained_for_negation!
          return unless count_constrained?

          constraint = @chains.map(&:first).find { |name| COUNT_CHAIN_NAMES.include?(name) }
          ::RSpec::Mocks.error_generator.raise_cant_constrain_count_for_negated_have_received_error(constraint)
        end

        def ensure_any_instance_spy!(klass)
          return if any_instance_execute_stubbed?(klass)

          ::RSpec::Mocks::ErrorGenerator.new(klass).raise_expectation_on_unstubbed_method(instance_execute_method)
        end

        def any_instance_execute_stubbed?(klass)
          recorder = ::RSpec::Mocks.space.any_instance_recorder_for(klass, true)
          return true if recorder&.already_observing?(instance_execute_method)

          instance_proxies(klass).any? do |proxy|
            method_double = proxy.method_double_if_exists_for_message(instance_execute_method)
            method_double&.stubs&.any?
          end
        end

        def instance_proxies(klass)
          ::RSpec::Mocks.space.proxies_of(klass)
        end

        def first_instance_proxy(klass)
          instance_proxies(klass).first
        end

        def instance_execute_method
          :execute
        end

        def constrained?
          @args.any? || @kwargs.any?
        end

        def ensure_task!(subject)
          return if subject.is_a?(Class) && subject <= CMDx::Task

          raise ArgumentError, "command must be a Task class"
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

        def count_description
          @chains.each do |name, args, _block|
            phrase =
              case name
              when :once then "once"
              when :twice then "twice"
              when :thrice then "thrice"
              when :exactly then "exactly #{args.first} times"
              when :at_least then "at least #{args.first} times"
              when :at_most then "at most #{args.first} times"
              end
            return phrase if phrase
          end

          nil
        end

      end
    end
  end
end
