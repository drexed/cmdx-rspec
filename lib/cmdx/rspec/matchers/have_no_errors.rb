# frozen_string_literal: true

module CMDx # :nodoc:
  module RSpec
    module Matchers
      # Asserts the subject's errors collection is empty.
      #
      # @see CMDx::RSpec::Matchers#have_no_errors
      #
      class HaveNoErrors

        INSTANCE = new

        # @return [String]
        def description
          "have no errors"
        end

        # @param actual [Object] value under test
        # @return [Boolean]
        def matches?(actual)
          @actual = actual
          errors = extract_errors(actual)
          return false if errors.nil?

          errors.empty?
        end

        # @return [String]
        def failure_message
          errors = extract_errors(@actual)
          "expected #{@actual.inspect} to have no errors, but had #{errors&.to_h.inspect}"
        end

        private

        def extract_errors(actual)
          case actual
          when CMDx::Errors then actual
          when CMDx::Result, CMDx::Task then actual.errors
          else actual.respond_to?(:errors) ? actual.errors : nil
          end
        end

      end
    end
  end
end
