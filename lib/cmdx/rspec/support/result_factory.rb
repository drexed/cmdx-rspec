# frozen_string_literal: true

module CMDx # :nodoc:
  module RSpec
    module Support
      # Builds frozen {CMDx::Result} values wired into a {CMDx::Chain}, matching
      # the shape {CMDx::Runtime} produces without invoking `work`.
      #
      # @api private
      module ResultFactory

        STUB_TASK = Class.new(CMDx::Task) do
          def self.name
            "CMDx::RSpec::StubTask"
          end
        end
        private_constant :STUB_TASK

        LIFECYCLE_KEYS = %i[root strict deprecated retries duration rolled_back tid].freeze
        private_constant :LIFECYCLE_KEYS

        extend self

        # @param status [Symbol, CMDx::Signal] outcome name or pre-built signal
        # @param reason [String, nil] human-readable outcome reason
        # @param cause [Exception, nil] originating exception
        # @param metadata [Hash] signal metadata payload
        # @param upstream_result [CMDx::Result, nil] required for `:echo`; must be failed
        # @return [CMDx::Signal]
        # @raise [ArgumentError] for unknown statuses or invalid echo input
        def coerce_signal(status, reason: nil, cause: nil, metadata: EMPTY_HASH, upstream_result: nil)
          case status
          when CMDx::Signal
            status
          when :success, :successful
            CMDx::Signal.success(reason, metadata:, cause:)
          when :skip, :skipped
            CMDx::Signal.skipped(reason, metadata:, cause:)
          when :fail, :failed, :failure
            CMDx::Signal.failed(reason, metadata:, cause:)
          when :echo, :echoed
            validate_echo_upstream!(upstream_result)
            CMDx::Signal.echoed(upstream_result, metadata:, cause:)
          else
            raise ArgumentError, "unknown result status #{status.inspect}"
          end
        end

        # @param signal [CMDx::Signal] outcome payload
        # @param task [Class, nil] task class for `result.task` (an internal stub when omitted)
        # @param chain [CMDx::Chain, nil] chain to join
        # @param context [Hash, CMDx::Context, nil] task context
        # @param options [Hash] lifecycle flags
        # @option options [Boolean] :root whether this result is the chain root
        # @option options [Boolean] :strict whether the result was produced via `execute!`
        # @option options [Boolean] :deprecated whether the result is flagged deprecated
        # @option options [Integer] :retries retry count beyond the first attempt
        # @option options [Float, nil] :duration execution duration in milliseconds
        # @option options [Boolean] :rolled_back whether rollback ran for this result
        # @option options [String, nil] :tid execution identifier (defaults to a uuid_v7)
        # @return [CMDx::Result] frozen result linked onto the chain
        def assemble(signal, task: nil, chain: nil, context: nil, **options)
          lifecycle = options.slice(*LIFECYCLE_KEYS)
          task_class = task || STUB_TASK
          task_instance = task_class.new(context.nil? ? EMPTY_HASH : context)
          chain ||= CMDx::Chain.new
          result = CMDx::Result.new(
            chain,
            task_instance,
            signal,
            root: lifecycle.fetch(:root, true),
            strict: lifecycle.fetch(:strict, false),
            deprecated: lifecycle.fetch(:deprecated, false),
            retries: lifecycle.fetch(:retries, 0),
            duration: lifecycle.fetch(:duration, nil),
            rolled_back: lifecycle.fetch(:rolled_back, false),
            tid: lifecycle.fetch(:tid, SecureRandom.uuid_v7)
          )

          chain.unshift(result)

          result
        end

        # Resolves an outcome chain into a signal, then delegates to {#assemble}.
        #
        # @param outcome_chains [Support::OutcomeChains] object including {Support::OutcomeChains}
        # @param task [Class, nil] task class for `result.task`
        # @param chain [CMDx::Chain, nil] chain to join (a new chain when omitted)
        # @param context [Hash, CMDx::Context] task context merged into the result
        # @param lifecycle [Hash] lifecycle flags including `:deprecated`
        # @return [CMDx::Result]
        # @raise [ArgumentError] when the outcome chain was not configured
        def assemble_from_outcome(outcome_chains, task: nil, chain: nil, context: nil, **lifecycle)
          outcome = outcome_chains.resolved_outcome
          raise ArgumentError, "outcome required" if outcome.nil?

          reason, cause, metadata, upstream = outcome_chains.signal_attributes
          signal = coerce_signal(
            outcome,
            reason:,
            cause:,
            metadata:,
            upstream_result: upstream
          )

          assemble(
            signal,
            task:,
            chain:,
            context:,
            deprecated: lifecycle.fetch(:deprecated, outcome_chains.deprecated?),
            **lifecycle.except(:deprecated)
          )
        end

        # Raises the way {CMDx::Runtime} does for a failed strict result:
        # the original exception when +cause+ is set and is not a {CMDx::Fault},
        # otherwise a {CMDx::Fault} wrapping the result.
        #
        # @param result [CMDx::Result] a failed strict result
        # @return [void]
        # @raise [CMDx::Fault, StandardError]
        def raise_strict_failure!(result)
          cause = result.cause
          raise(cause) if cause && !cause.is_a?(CMDx::Fault)

          raise(CMDx::Fault, result.caused_failure, cause:)
        end

        # Guards `:echo` outcomes so only failed upstream results are accepted.
        #
        # @param upstream_result [CMDx::Result] failed result echoed by `:echo` outcomes
        # @return [void]
        # @raise [ArgumentError] when +upstream_result+ is not a failed result
        def validate_echo_upstream!(upstream_result)
          return if upstream_result.is_a?(CMDx::Result) && upstream_result.failed?

          raise ArgumentError, "upstream result must be a failed CMDx::Result"
        end

      end
    end
  end
end
