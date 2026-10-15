# frozen_string_literal: true

module CMDx # :nodoc:
  module RSpec
    module Support
      # Lazy wrapper returned once a {Result} fixture has enough configuration
      # to produce a {CMDx::Result}. Chains lifecycle and output tweaks, then
      # materializes on {CMDx::Result} API calls or explicit {#build}.
      #
      # @see Result
      class ResultDeferred

        BUILDER_CHAIN = %i[
          strict as_root with_retries with_duration rolled_back with_tid
          and_output as_deprecated
        ].freeze
        private_constant :BUILDER_CHAIN

        # Wraps a configured {Result} builder for lazy materialization.
        #
        # @param builder [Result] configured {Result} fixture builder
        # @return [void]
        def initialize(builder)
          @builder = builder
          @materialize = nil
        end

        # @return [CMDx::Result]
        def build
          materialize
        end

        BUILDER_CHAIN.each do |method_name|
          define_method(method_name) do |*args, **kwargs, &block|
            @builder.public_send(method_name, *args, **kwargs, &block)
            self
          end
        end

        # @param other [Object] object compared for equality
        # @return [Boolean]
        def ==(other)
          materialize == other
        end

        # @param other [Object] object compared for equality
        # @return [Boolean]
        def eql?(other)
          materialize.eql?(other)
        end

        # @return [Integer]
        def hash
          materialize.hash
        end

        # @return [String]
        def inspect
          materialized? ? build.inspect : "#<#{self.class.name} pending>"
        end

        # @return [Boolean]
        def materialized?
          !@materialize.nil?
        end

        # @return [CMDx::Result]
        def materialize
          @materialize ||= @builder.build
        end

        # @param name [Symbol] method name being checked
        # @param include_private [Boolean] whether private methods count for dispatch
        # @return [Boolean]
        def respond_to_missing?(name, include_private = false)
          materialize.respond_to?(name, include_private)
        end

        private

        def method_missing(name, ...)
          materialize.public_send(name, ...)
        end

      end
    end
  end
end
