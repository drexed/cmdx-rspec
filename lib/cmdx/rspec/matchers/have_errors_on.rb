# frozen_string_literal: true

module CMDx # :nodoc:
  module RSpec
    module Matchers
      # Asserts {CMDx::Errors} (or `#errors`) include messages under +key+.
      #
      # Accepts a {CMDx::Result}, {CMDx::Task}, {CMDx::Errors}, or any object
      # responding to `#errors`.
      #
      # @see CMDx::RSpec::Matchers#have_errors_on
      #
      class HaveErrorsOn

        # @param key [Symbol] context key with errors
        # @param messages [Array<String>] expected error messages
        def initialize(key, messages)
          @key = key
          @messages = messages
        end

        # @return [String]
        def description
          if @messages.empty?
            "have errors on #{@key.inspect}"
          else
            "have errors on #{@key.inspect} matching #{@messages.inspect}"
          end
        end

        # @param actual [Object] value under test
        # @return [Boolean]
        def matches?(actual)
          @actual = actual
          errors = extract_errors(actual)
          return false if errors.nil?
          return false unless errors.key?(@key)

          @messages.all? { |m| errors.added?(@key, m) }
        end

        # @return [String]
        def failure_message
          errors = extract_errors(@actual)
          if errors.nil?
            "expected #{@actual.inspect} to expose an Errors collection"
          elsif !errors.key?(@key)
            "expected errors on #{@key.inspect}, but only had: #{errors.keys.inspect}"
          else
            "expected errors on #{@key.inspect} to include #{@messages.inspect}, but had #{errors[@key].inspect}"
          end
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
