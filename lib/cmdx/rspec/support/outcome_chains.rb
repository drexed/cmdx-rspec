# frozen_string_literal: true

module CMDx # :nodoc:
  module RSpec
    module Support
      # Shared outcome chain methods for {CMDx::RSpec::Result} and
      # {CMDx::RSpec::Matchers::Execute}.
      #
      # @api private
      module OutcomeChains

        OUTCOME_VERBS = {
          success: "succeed",
          skipped: "skip",
          failed: "fail",
          echo: "throw"
        }.freeze

        # @return [void]
        def initialize_outcome_chains
          @outcome = nil
          @outcome_options = {}
          @output = {}
          @error = nil
          @deprecated = false
        end

        # @param metadata [Hash] payload exposed via `result.metadata`
        # @return [self]
        # @raise [ArgumentError] when a different outcome was already set
        def and_succeed(metadata: nil)
          set_outcome(:success, metadata: metadata.nil? ? EMPTY_HASH : metadata)
        end

        # @param reason [String, nil] human-readable skip reason
        # @param cause [Exception, nil] originating cause attached to the signal
        # @param metadata [Hash] payload exposed via `result.metadata`
        # @return [self]
        # @raise [ArgumentError] when a different outcome was already set
        def and_skip(reason: nil, cause: nil, metadata: nil)
          set_outcome(:skipped, reason:, cause:, metadata: metadata.nil? ? EMPTY_HASH : metadata)
        end

        # @param reason [String, nil] human-readable failure reason
        # @param cause [Exception, nil] originating cause attached to the signal
        # @param metadata [Hash] payload exposed via `result.metadata`
        # @return [self]
        # @raise [ArgumentError] when a different outcome was already set
        def and_fail(reason: nil, cause: nil, metadata: nil)
          set_outcome(:failed, reason:, cause:, metadata: metadata.nil? ? EMPTY_HASH : metadata)
        end

        # @param upstream_result [CMDx::Result] the originating failure; must be failed
        # @param metadata [Hash] payload exposed via `result.metadata`
        # @return [self]
        # @raise [ArgumentError] when +upstream_result+ is not a failed result,
        #   or when a different outcome was already set
        def and_throw(upstream_result, metadata: nil)
          ResultFactory.validate_echo_upstream!(upstream_result)
          set_outcome(:echo, upstream_result:, metadata: metadata.nil? ? EMPTY_HASH : metadata)
        end

        # Merges +context+ into the result context.
        #
        # @param context [Hash{Symbol => Object}] keys appended to the result context
        # @return [self]
        def and_output(**context)
          @output.merge!(context)
          self
        end

        # Flags the result deprecated. Implies success when no outcome was set.
        #
        # @return [self]
        def as_deprecated
          @deprecated = true
          self
        end

        # Sets the failure cause from an exception class or instance. Implies
        # failure when no outcome was set. Derives `reason` as
        # `"[ExceptionClass] message"` unless {#and_fail} already set one.
        #
        # @param exception [Class, Exception] rescued error, or an instance to use as `cause`
        # @param message [String, nil] message used when +exception+ is a class
        # @return [self]
        # @raise [ArgumentError] when a non-failure outcome was already set,
        #   or when an error was already set
        def with_error(exception, message = nil)
          raise ArgumentError, "outcome already set" if @outcome && @outcome != :failed
          raise ArgumentError, "error already set" if @error

          @outcome = :failed
          @error = [exception, message]
          self
        end

        # @return [Symbol, nil] resolved outcome status
        def resolved_outcome
          return @outcome if @outcome
          return :success if @deprecated || @output.any?

          nil
        end

        # @return [Boolean]
        def outcome?
          !resolved_outcome.nil?
        end

        # @return [Boolean] whether the result is flagged deprecated
        def deprecated?
          @deprecated
        end

        # @return [Array(String, Exception, Hash, CMDx::Result)] reason, cause, metadata, upstream
        def signal_attributes
          reason = @outcome_options[:reason]
          cause = @outcome_options[:cause]
          metadata = @outcome_options.fetch(:metadata, EMPTY_HASH)
          upstream = @outcome_options[:upstream_result]

          if @error
            exception, message = @error
            cause = exception.is_a?(Class) ? exception.new(message || "stubbed") : exception
            reason ||= "[#{cause.class}] #{cause.message}"
          end

          [reason, cause, metadata, upstream]
        end

        private

        def set_outcome(status, **options)
          raise ArgumentError, "outcome already set" if @outcome && @outcome != status

          @outcome = status
          @outcome_options.merge!(options)
          self
        end

      end
    end
  end
end
