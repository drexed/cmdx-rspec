# frozen_string_literal: true

module CMDx # :nodoc:
  module RSpec
    module Matchers
      # Asserts the root {CMDx::Result} on a chain belongs to +task_class+ (subclass match).
      #
      # Accepts a {CMDx::Chain} or any {CMDx::Result} (uses `result.chain`).
      #
      # @see CMDx::RSpec::Matchers#have_chain_root
      #
      class HaveChainRoot

        # @param task_class [Class] expected root task class
        def initialize(task_class)
          @task_class = task_class
        end

        # @return [String]
        def description
          "have chain root #{@task_class}"
        end

        # @param actual [CMDx::Chain, CMDx::Result] chain or result exposing a chain
        # @return [Boolean]
        def matches?(actual)
          @actual = actual
          chain = extract_chain(actual)
          return false if chain.nil?
          return false if chain.root.nil?

          chain.root.task <= @task_class
        end

        # @return [String]
        def failure_message
          chain = extract_chain(@actual)
          "expected chain root to be #{@task_class}, but was #{chain&.root&.task.inspect}"
        end

        private

        def extract_chain(actual)
          case actual
          when CMDx::Chain  then actual
          when CMDx::Result then actual.chain
          end
        end

      end
    end
  end
end
