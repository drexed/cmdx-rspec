# frozen_string_literal: true

module CMDx # :nodoc:
  module RSpec
    module Matchers
      module Support
        # Shared `.once` / `.exactly(n)` chains for cardinality assertions.
        #
        # @api private
        module CountChains

          private

          def initialize_count_chains
            @count_chain = nil
          end

          # @return [String, nil]
          def count_chain_description
            kind, value = @count_chain
            case kind
            when :exactly
              case value
              when 1 then "once"
              when 2 then "twice"
              when 3 then "thrice"
              else "exactly #{value} times"
              end
            when :at_least then "at least #{value} times"
            when :at_most then "at most #{value} times"
            end
          end

          # @param actual_count [Integer] observed occurrence count
          # @return [Boolean]
          def count_chain_satisfied?(actual_count)
            return default_count_satisfied?(actual_count) if @count_chain.nil?

            kind, value = @count_chain
            case kind
            when :exactly then actual_count == value
            when :at_least then actual_count >= value
            when :at_most then actual_count <= value
            else false
            end
          end

          # @param actual_count [Integer] observed occurrence count
          # @return [Boolean]
          def default_count_satisfied?(actual_count)
            actual_count >= 1
          end

          public

          # Requires exactly one matching occurrence (alias for `.exactly(1)`).
          #
          # @return [Object] including class
          def once
            @count_chain = [:exactly, 1]
            self
          end

          # @return [Object] including class
          def twice
            @count_chain = [:exactly, 2]
            self
          end

          # @return [Object] including class
          def thrice
            @count_chain = [:exactly, 3]
            self
          end

          # Requires an exact occurrence count.
          #
          # @param count [Integer] expected occurrence count
          # @return [Object] including class
          def exactly(count)
            @count_chain = [:exactly, count]
            self
          end

          # @param count [Integer] expected occurrence count
          # @return [Object] including class
          def at_least(count)
            @count_chain = [:at_least, count]
            self
          end

          # @param count [Integer] expected occurrence count
          # @return [Object] including class
          def at_most(count)
            @count_chain = [:at_most, count]
            self
          end

        end
      end
    end
  end
end
