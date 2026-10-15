# frozen_string_literal: true

module CMDx # :nodoc:
  module RSpec
    module Matchers
      # Asserts a Task's `middlewares` registry includes +middleware+.
      #
      # @see CMDx::RSpec::Matchers#have_middleware
      #
      class HaveMiddleware

        # @param middleware [Class, Module, Object] expected middleware entry
        def initialize(middleware)
          @middleware = middleware
        end

        # @return [String]
        def description
          "have middleware #{@middleware.inspect}"
        end

        # @param actual [Class, CMDx::Task] task class or instance under test
        # @return [Boolean]
        def matches?(actual)
          @actual = actual
          target = actual.is_a?(Class) ? actual : actual.class
          return false unless target.respond_to?(:middlewares)

          target.middlewares.registry.any? do |entry|
            m, = entry
            case @middleware
            when Class then m.is_a?(@middleware) || m == @middleware
            else m == @middleware
            end
          end
        end

        # @return [String]
        def failure_message
          target = @actual.is_a?(Class) ? @actual : @actual.class
          "expected #{target} to register middleware #{@middleware.inspect}, but had #{target.middlewares.registry.inspect}"
        end

      end
    end
  end
end
