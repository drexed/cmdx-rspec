# frozen_string_literal: true

module CMDx # :nodoc:
  module RSpec
    module Matchers
      # Asserts +tag+ appears on a {CMDx::Result}, Task class settings, or `#tags`.
      #
      # @see CMDx::RSpec::Matchers#have_tag
      #
      class HaveTag

        # @param tag [Symbol, String] expected metadata tag
        def initialize(tag)
          @tag = tag
        end

        # @return [String]
        def description
          "have tag #{@tag.inspect}"
        end

        # @param actual [Object] value under test
        # @return [Boolean]
        def matches?(actual)
          @actual = actual
          extract_tags(actual).include?(@tag)
        end

        # @return [String]
        def failure_message
          tags = extract_tags(@actual)
          "expected #{@actual} to have tag #{@tag.inspect}, but had #{tags.inspect}"
        end

        private

        def extract_tags(actual)
          case actual
          when CMDx::Result
            actual.tags
          when Class
            actual.respond_to?(:settings) ? actual.settings.tags : EMPTY_ARRAY
          else
            actual.respond_to?(:tags) ? actual.tags : EMPTY_ARRAY
          end
        end

      end
    end
  end
end
