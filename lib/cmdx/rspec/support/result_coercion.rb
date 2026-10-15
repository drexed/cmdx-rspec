# frozen_string_literal: true

module CMDx # :nodoc:
  module RSpec
    module Support
      # Normalizes {Support::ResultDeferred} fixtures to {CMDx::Result} for matchers.
      #
      # @api private
      module ResultCoercion

        extend self

        # Materializes deferred fixtures, then validates the value is a {CMDx::Result}.
        #
        # @param value [CMDx::Result, Support::ResultDeferred] result or deferred fixture to normalize
        # @return [CMDx::Result]
        # @raise [ArgumentError] when +value+ is not a result or deferred fixture
        def materialize!(value)
          case value
          when ResultDeferred then value.materialize
          when CMDx::Result then value
          else raise ArgumentError, "must be a CMDx::Result"
          end
        end

      end
    end
  end
end
