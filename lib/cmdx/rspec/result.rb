# frozen_string_literal: true

module CMDx # :nodoc:
  module RSpec
    # Fluent builder for frozen {CMDx::Result} fixtures. Outcome chains mirror
    # {CMDx::RSpec::Matchers::Execute} (`and_succeed`, `and_fail`, …).
    #
    # @see CMDx::RSpec::Matchers#build_result
    class Result

      include Support::OutcomeChains
      include Support::ResultFinisher

      # Seeds context keys (same role as keyword args on {CMDx::RSpec::Matchers#execute}).
      #
      # @param task [Class, nil] task class for `result.task`
      # @param context [Hash{Symbol => Object}] initial context merged into {#and_output}
      # @return [Result]
      def self.for(task = nil, **context)
        builder = new
        builder.on(task) if task
        builder.and_output(**context) unless context.empty?
        builder
      end

      # @return [void]
      def initialize
        initialize_outcome_chains
        @task = nil
        @chain = nil
        @explicit_context = nil
        @signal = nil
        @lifecycle = {}
      end

      # @param task [Class] task class for `result.task`
      # @return [self]
      def on(task)
        @task = task
        self
      end

      # @param chain [CMDx::Chain] chain to append onto
      # @return [self]
      def on_chain(chain)
        @chain = chain
        self
      end

      # @param context [Hash, CMDx::Context] task context (replaces implicit output hash)
      # @return [self]
      def with_context(context)
        @explicit_context = context
        self
      end

      # Uses a pre-built signal instead of an outcome chain.
      #
      # @param signal [CMDx::Signal] pre-built outcome signal
      # @return [self]
      def from_signal(signal)
        @signal = signal
        maybe_deferred
      end

      # Records whether the fixture simulates `execute!` (`strict: true`).
      #
      # @param value [Boolean] flag value to record on the fixture
      # @return [self]
      def strict(value: true)
        @lifecycle[:strict] = value
        self
      end

      # Records whether the fixture is the chain root result.
      #
      # @param value [Boolean] flag value to record on the fixture
      # @return [self]
      def as_root(value: true)
        @lifecycle[:root] = value
        self
      end

      # @param count [Integer] retry count beyond the first attempt
      # @return [self]
      def with_retries(count)
        @lifecycle[:retries] = count
        self
      end

      # @param milliseconds [Float, nil] execution duration in milliseconds
      # @return [self]
      def with_duration(milliseconds)
        @lifecycle[:duration] = milliseconds
        self
      end

      # Records whether rollback ran for the fixture.
      #
      # @param value [Boolean] flag value to record on the fixture
      # @return [self]
      def rolled_back(value: true)
        @lifecycle[:rolled_back] = value
        self
      end

      # @param tid [String] execution identifier
      # @return [self]
      def with_tid(tid)
        @lifecycle[:tid] = tid
        self
      end

      # Materializes a frozen {CMDx::Result} from the configured signal or outcome chain.
      #
      # @return [CMDx::Result] frozen result linked onto its chain
      # @raise [ArgumentError] when neither a signal nor an outcome chain was configured
      def build
        if @signal
          Support::ResultFactory.assemble(
            @signal,
            task: @task,
            chain: @chain,
            context: assembly_context,
            deprecated: @deprecated,
            **@lifecycle
          )
        else
          Support::ResultFactory.assemble_from_outcome(
            self,
            task: @task,
            chain: @chain,
            context: assembly_context,
            **@lifecycle
          )
        end
      end

      private

      def assembly_context
        return @explicit_context if @explicit_context

        @output
      end

    end
  end
end
