# frozen_string_literal: true

module CMDx # :nodoc:
  module RSpec
    module Support
      # Wraps {Result} in {Support::ResultDeferred} after outcome configuration so
      # fixtures materialize without a trailing `.build`.
      #
      # @api private
      module ResultFinisher

        OUTCOME_METHODS = %i[and_succeed and_skip and_fail with_error].freeze
        private_constant :OUTCOME_METHODS

        OUTCOME_METHODS.each do |method_name|
          define_method(method_name) do |*args, **kwargs, &block|
            super(*args, **kwargs, &block)
            maybe_deferred
          end
        end

        # Echoes a failed upstream result, then returns a deferred fixture when configured.
        #
        # @param upstream_result [CMDx::Result, Support::ResultDeferred] failed result to echo (materialized when deferred)
        # @param metadata [Hash] signal metadata payload
        # @return [Support::ResultDeferred]
        def and_throw(upstream_result, metadata: nil)
          upstream_result = upstream_result.build if upstream_result.is_a?(ResultDeferred)

          super
          maybe_deferred
        end

        # Wraps the builder in {Support::ResultDeferred} once an outcome is ready to build.
        #
        # @return [Support::ResultDeferred] when a signal or outcome is configured
        # @return [Result] otherwise
        def maybe_deferred
          return ResultDeferred.new(self) if @signal || outcome?

          self
        end

      end
    end
  end
end
