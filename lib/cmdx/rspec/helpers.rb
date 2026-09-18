# frozen_string_literal: true

module CMDx
  module RSpec
    # RSpec helpers for stubbing and asserting Task execution. Each helper
    # builds a frozen {CMDx::Result} carrying the requested {CMDx::Signal}
    # and wires it into a fresh {CMDx::Chain} so callers see realistic
    # execution output without invoking the Task's `work`.
    #
    # Mix into example groups via `config.include CMDx::RSpec::Helpers`.
    module Helpers

      # Anonymous task used by result builders when no +task+ is supplied.
      STUB_TASK = Class.new(CMDx::Task) do
        def self.name
          "CMDx::RSpec::StubTask"
        end
      end
      private_constant :STUB_TASK

      # Builds a frozen {CMDx::Result} without stubbing task execution.
      # Use when a collaborator must return a result, when seeding a chain,
      # or anywhere a real result is needed outside `stub_task_*`.
      #
      # @param status [Symbol, CMDx::Signal] `:success`, `:skipped`, `:failed`,
      #   `:echo`, or a pre-built signal
      # @param reason [String, nil] human-readable outcome reason
      # @param cause [Exception, nil] originating exception on failure
      # @param metadata [Hash] signal metadata payload
      # @param upstream_result [CMDx::Result] required for `:echo`; must be failed
      # @param task [Class] task class for `result.task` (defaults to an internal stub)
      # @param chain [CMDx::Chain, nil] chain to join (a fresh one is created when omitted)
      # @param context [Hash, CMDx::Context, nil] task context; other keyword args
      #   are forwarded to `task.new` when +context+ is omitted
      # @param root [Boolean] whether this result is the chain root
      # @param strict [Boolean] whether the result was produced via `execute!`
      # @param deprecated [Boolean] whether the result is flagged deprecated
      # @param retries [Integer] retry count beyond the first attempt
      # @param duration [Float, nil] execution duration in milliseconds
      # @param rolled_back [Boolean] whether rollback ran for this result
      # @param tid [String, nil] execution identifier (defaults to a uuid_v7)
      # @return [CMDx::Result]
      # @raise [ArgumentError] for unknown statuses or invalid echo input
      # @example
      #   result = build_result(:success, snapshot:)
      #   allow(FetchSnapshot).to receive(:execute).and_return(result)
      def build_result(status, **options)
        signal = resolve_result_signal(
          status,
          reason: options[:reason],
          cause: options[:cause],
          metadata: options.fetch(:metadata, {}),
          upstream_result: options[:upstream_result]
        )

        assemble_result(signal, **options.except(:reason, :cause, :metadata, :upstream_result))
      end

      # @return [CMDx::Result] a successful result (`state: complete`, `status: success`)
      # @see #build_result
      def build_successful_result(metadata: {}, **context)
        build_result(:success, metadata:, **context)
      end

      # @return [CMDx::Result] a skipped result (`state: interrupted`, `status: skipped`)
      # @see #build_result
      def build_skipped_result(reason: nil, cause: nil, metadata: {}, **context)
        build_result(:skipped, reason:, cause:, metadata:, **context)
      end

      # @return [CMDx::Result] a failed result (`state: interrupted`, `status: failed`)
      # @see #build_result
      def build_failed_result(reason: nil, cause: nil, metadata: {}, **context)
        build_result(:failed, reason:, cause:, metadata:, **context)
      end

      # @param upstream_result [CMDx::Result] the failed result being propagated
      # @return [CMDx::Result] a failed result echoing +upstream_result+
      # @see #build_result
      def build_echoed_result(upstream_result, metadata: {}, **context)
        build_result(:echo, upstream_result:, metadata:, **context)
      end

      # Stubs `command.execute` to return a frozen successful Result.
      #
      # @param command [Class] the Task class to stub
      # @param metadata [Hash] payload exposed via `result.metadata`
      # @param context [Hash{Symbol => Object}] context overrides forwarded to `command.new`
      # @return [CMDx::Result] the frozen Result installed on the stub
      # @example
      #   stub_task_success(SomeTask, metadata: { id: 1 })
      def stub_task_success(command, metadata: {}, **context)
        build_stub(command, :execute, CMDx::Signal.success(nil, metadata:), context)
      end

      # Stubs `command.execute!` (bang variant) to return a frozen successful Result.
      #
      # @param command [Class] the Task class to stub
      # @param metadata [Hash] payload exposed via `result.metadata`
      # @param context [Hash{Symbol => Object}] context overrides forwarded to `command.new`
      # @return [CMDx::Result] the frozen Result installed on the stub
      def stub_task_success!(command, metadata: {}, **context)
        build_stub(command, :execute!, CMDx::Signal.success(nil, metadata:), context, strict: true)
      end

      # Stubs `command.execute` to return a frozen skipped Result.
      #
      # @param command [Class] the Task class to stub
      # @param reason [String, nil] human-readable skip reason
      # @param cause [Exception, nil] originating cause attached to the signal
      # @param metadata [Hash] payload exposed via `result.metadata`
      # @param context [Hash{Symbol => Object}] context overrides forwarded to `command.new`
      # @return [CMDx::Result] the frozen Result installed on the stub
      def stub_task_skip(command, reason: nil, cause: nil, metadata: {}, **context)
        build_stub(command, :execute, CMDx::Signal.skipped(reason, metadata:, cause:), context)
      end

      # Stubs `command.execute!` (bang variant) to return a frozen skipped Result.
      #
      # @param command [Class] the Task class to stub
      # @param reason [String, nil] human-readable skip reason
      # @param cause [Exception, nil] originating cause attached to the signal
      # @param metadata [Hash] payload exposed via `result.metadata`
      # @param context [Hash{Symbol => Object}] context overrides forwarded to `command.new`
      # @return [CMDx::Result] the frozen Result installed on the stub
      def stub_task_skip!(command, reason: nil, cause: nil, metadata: {}, **context)
        build_stub(command, :execute!, CMDx::Signal.skipped(reason, metadata:, cause:), context, strict: true)
      end

      # Stubs `command.execute` to return a frozen failed Result.
      #
      # @param command [Class] the Task class to stub
      # @param reason [String, nil] human-readable failure reason
      # @param cause [Exception, nil] originating cause attached to the signal
      # @param metadata [Hash] payload exposed via `result.metadata`
      # @param context [Hash{Symbol => Object}] context overrides forwarded to `command.new`
      # @return [CMDx::Result] the frozen Result installed on the stub
      def stub_task_fail(command, reason: nil, cause: nil, metadata: {}, **context)
        build_stub(command, :execute, CMDx::Signal.failed(reason, metadata:, cause:), context)
      end

      # Stubs `command.execute!` (bang variant) to return a frozen failed Result.
      #
      # @param command [Class] the Task class to stub
      # @param reason [String, nil] human-readable failure reason
      # @param cause [Exception, nil] originating cause attached to the signal
      # @param metadata [Hash] payload exposed via `result.metadata`
      # @param context [Hash{Symbol => Object}] context overrides forwarded to `command.new`
      # @return [CMDx::Result] the frozen Result installed on the stub
      def stub_task_fail!(command, reason: nil, cause: nil, metadata: {}, **context)
        build_stub(command, :execute!, CMDx::Signal.failed(reason, metadata:, cause:), context, strict: true)
      end

      # Stubs `command.execute` to return a frozen failed Result whose
      # `cause` is an instance of +exception+. Models the "rescued
      # StandardError -> failed signal" path that Runtime takes when a
      # task's `work` raises something other than a Fault.
      #
      # @param command [Class] the Task class to stub
      # @param exception [Class<StandardError>, StandardError] the cause
      # @param message [String, nil] message used when constructing the
      #   exception (when +exception+ is a Class) and to derive the reason
      # @param metadata [Hash]
      # @param context [Hash{Symbol => Object}]
      # @return [CMDx::Result] the frozen Result installed on the stub
      # @example
      #   stub_task_error(MyCommand, Net::OpenTimeout, "boom")
      def stub_task_error(command, exception, message = nil, metadata: {}, **context)
        ex = exception.is_a?(Class) ? exception.new(message || "stubbed") : exception
        reason = "[#{ex.class}] #{ex.message}"
        build_stub(command, :execute, CMDx::Signal.failed(reason, metadata:, cause: ex), context)
      end

      # Stubs `command.execute` to return a frozen failed Result that
      # echoes +upstream_result+. Models the `throw!`-then-propagate path
      # used by nested tasks/workflows.
      #
      # @param command [Class] the Task class to stub
      # @param upstream_result [CMDx::Result] the originating failure
      # @param metadata [Hash]
      # @param context [Hash{Symbol => Object}]
      # @return [CMDx::Result] the frozen Result installed on the stub
      def stub_task_throw(command, upstream_result, metadata: {}, **context)
        unless upstream_result.is_a?(CMDx::Result) && upstream_result.failed?
          raise ArgumentError,
                "upstream_result must be a failed CMDx::Result"
        end

        build_stub(command, :execute, CMDx::Signal.echoed(upstream_result, metadata:), context)
      end

      # Stubs `command.execute` to return a successful Result flagged as
      # `deprecated?`. Useful when asserting deprecation surfaces without
      # triggering the real `Deprecation` action.
      #
      # @param command [Class] the Task class to stub
      # @param metadata [Hash]
      # @param context [Hash{Symbol => Object}]
      # @return [CMDx::Result]
      def stub_task_deprecated(command, metadata: {}, **context)
        build_stub(command, :execute, CMDx::Signal.success(nil, metadata:), context, deprecated: true)
      end

      # Captures lines written to a temporary CMDx logger for the duration
      # of the block. Restores the previous logger on exit.
      #
      # @yield runs the block with `CMDx.configuration.logger` swapped
      # @return [Array<String>] captured log lines
      # @example
      #   logs = capture_cmdx_logs { MyCommand.execute }
      #   expect(logs.join).to include("status=success")
      def capture_cmdx_logs(&)
        raise ArgumentError, "block required" unless block_given?

        io = StringIO.new
        previous = CMDx.configuration.logger
        CMDx.configuration.logger = Logger.new(io, formatter: previous&.formatter || CMDx::LogFormatters::Line.new)
        yield
        io.string.lines.map(&:chomp)
      ensure
        CMDx.configuration.logger = previous if previous
      end

      # Subscribes to telemetry events on +command+'s telemetry registry
      # for the duration of the block. Captures every emitted event.
      # Tasks subclassing +command+ also fire (telemetry is cloned at
      # class definition; the registry array is shared by reference until
      # +dup+).
      #
      # @param command [Class] the Task class whose telemetry to listen on
      # @param events [Array<Symbol>] event names to subscribe to;
      #   defaults to all of {CMDx::Telemetry::EVENTS}
      # @yield runs the block with subscribers attached
      # @return [Array<CMDx::Telemetry::Event>] captured events in emission order
      # @example
      #   events = subscribe_telemetry(MyCommand, :task_executed) { MyCommand.execute }
      #   expect(events.map(&:name)).to eq([:task_executed])
      def subscribe_telemetry(command, *events, &)
        raise ArgumentError, "block required" unless block_given?

        events    = CMDx::Telemetry::EVENTS if events.empty?
        captured  = []
        telemetry = command.telemetry
        listener  = ->(event) { captured << event }

        events.each { |e| telemetry.subscribe(e, listener) }
        begin
          yield
        ensure
          events.each { |e| telemetry.unsubscribe(e, listener) }
        end

        captured
      end

      # Captures the {CMDx::Chain} produced by +command+'s execution
      # within the block. Subscribes to +command+'s `:task_executed`
      # telemetry to grab the chain reference before Runtime teardown
      # clears it.
      #
      # @param command [Class] the Task class whose chain to capture
      # @yield the block to execute
      # @return [CMDx::Chain, nil] the chain (frozen by Runtime), or nil
      #   when +command+ didn't run as a root during the block
      # @example
      #   chain = with_cmdx_chain(MyWorkflow) { MyWorkflow.execute }
      #   expect(chain.size).to be > 1
      def with_cmdx_chain(command)
        raise ArgumentError, "block required" unless block_given?

        captured  = nil
        telemetry = command.telemetry
        listener  = lambda do |event|
          captured ||= event.payload[:result].chain if event.root
        end

        telemetry.subscribe(:task_executed, listener)
        begin
          yield
        ensure
          telemetry.unsubscribe(:task_executed, listener)
        end

        captured
      end

      # Restores `command.execute` to its original implementation.
      # When `context` is supplied, only the matching argument signature is unstubbed.
      #
      # @param command [Class] the Task class to unstub
      # @param context [Hash{Symbol => Object}] argument signature whose stub to release
      # @return [void]
      def unstub_task(command, **context)
        if context.empty?
          allow(command).to receive(:execute).and_call_original
        else
          allow(command).to receive(:execute).with(**context).and_call_original
        end
      end

      # Restores `command.execute!` to its original implementation.
      # When `context` is supplied, only the matching argument signature is unstubbed.
      #
      # @param command [Class] the Task class to unstub
      # @param context [Hash{Symbol => Object}] argument signature whose stub to release
      # @return [void]
      def unstub_task!(command, **context)
        if context.empty?
          allow(command).to receive(:execute!).and_call_original
        else
          allow(command).to receive(:execute!).with(**context).and_call_original
        end
      end

      # Sets a positive message expectation that `command.execute` is invoked.
      # When `context` is supplied, the expectation is constrained to that signature.
      #
      # @param command [Class] the Task class to expect
      # @param context [Hash{Symbol => Object}] argument signature to match
      # @return [RSpec::Mocks::MessageExpectation]
      def expect_task_execution(command, **context)
        if context.empty?
          expect(command).to receive(:execute)
        else
          expect(command).to receive(:execute).with(**context)
        end
      end

      # Sets a positive message expectation that `command.execute!` is invoked.
      # When `context` is supplied, the expectation is constrained to that signature.
      #
      # @param command [Class] the Task class to expect
      # @param context [Hash{Symbol => Object}] argument signature to match
      # @return [RSpec::Mocks::MessageExpectation]
      def expect_task_execution!(command, **context)
        if context.empty?
          expect(command).to receive(:execute!)
        else
          expect(command).to receive(:execute!).with(**context)
        end
      end

      # Sets a negative message expectation that `command.execute` is not invoked.
      # When `context` is supplied, only the matching signature is forbidden.
      #
      # @param command [Class] the Task class to guard
      # @param context [Hash{Symbol => Object}] argument signature to forbid
      # @return [RSpec::Mocks::MessageExpectation]
      def expect_no_task_execution(command, **context)
        if context.empty?
          expect(command).not_to receive(:execute)
        else
          expect(command).not_to receive(:execute).with(**context)
        end
      end

      # Sets a negative message expectation that `command.execute!` is not invoked.
      # When `context` is supplied, only the matching signature is forbidden.
      #
      # @param command [Class] the Task class to guard
      # @param context [Hash{Symbol => Object}] argument signature to forbid
      # @return [RSpec::Mocks::MessageExpectation]
      def expect_no_task_execution!(command, **context)
        if context.empty?
          expect(command).not_to receive(:execute!)
        else
          expect(command).not_to receive(:execute!).with(**context)
        end
      end

      # Yields each distinct Task class reachable from a Workflow's pipeline,
      # in first-seen order, so callers can stub them in a single block.
      #
      # @param command [Class] a Workflow class (must include `CMDx::Workflow`)
      # @yieldparam task [Class] a Task class referenced by the workflow pipeline
      # @return [void]
      # @raise [ArgumentError] when no block is given or `command` is not a Workflow
      # @example
      #   stub_workflow_tasks(MyWorkflow) { |t| stub_task_success(t) }
      def stub_workflow_tasks(command, &)
        if !block_given?
          raise ArgumentError, "block required"
        elsif !command.include?(Workflow)
          raise ArgumentError, "#{command.inspect} must be a workflow"
        end

        command.pipeline.flat_map(&:tasks).uniq.each(&)
      end

      private

      # @api private
      def resolve_result_signal(status, reason:, cause:, metadata:, upstream_result:)
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

      # @api private
      def validate_echo_upstream!(upstream_result)
        return if upstream_result.is_a?(CMDx::Result) && upstream_result.failed?

        raise ArgumentError, "upstream_result must be a failed CMDx::Result"
      end

      # Constructs a frozen {CMDx::Result} from +signal+ and wires it into a
      # {CMDx::Chain} so callers observe the same shape as a real execution.
      #
      # @api private
      # @return [CMDx::Result]
      LIFECYCLE_OPTIONS = %i[root strict deprecated retries duration rolled_back tid].freeze
      private_constant :LIFECYCLE_OPTIONS

      def assemble_result(signal, task: nil, chain: nil, context: nil, **options)
        context_data = options.except(*LIFECYCLE_OPTIONS)
        task_class    = task || STUB_TASK
        context_input = context || context_data
        task_instance = task_class.new(context_input)
        chain       ||= CMDx::Chain.new
        result        = CMDx::Result.new(
          chain,
          task_instance,
          signal,
          root: options.fetch(:root, true),
          strict: options.fetch(:strict, false),
          deprecated: options.fetch(:deprecated, false),
          retries: options.fetch(:retries, 0),
          duration: options.fetch(:duration, nil),
          rolled_back: options.fetch(:rolled_back, false),
          tid: options.fetch(:tid, SecureRandom.uuid_v7)
        )

        chain.unshift(result)

        result
      end

      # Constructs a frozen {CMDx::Result} from `signal` and stubs `command.method`
      # to return it.
      #
      # @api private
      # @param command [Class] the Task class being stubbed
      # @param method [Symbol] the message to stub (`:execute` or `:execute!`)
      # @param signal [CMDx::Signal] outcome payload to wrap
      # @param context [Hash] context overrides for `command.new`
      # @return [CMDx::Result] the frozen Result installed on the stub
      def build_stub(command, method, signal, context, **)
        result = assemble_result(signal, task: command, context:, **)
        allow(command).to receive(method).and_return(result)
        result
      end

    end
  end
end
