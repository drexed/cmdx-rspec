# frozen_string_literal: true

require "stringio"

module CMDx # :nodoc:
  module RSpec
    module Matchers
      module Support
        # Swaps `CMDx.configuration.logger` for the duration of a block.
        #
        # @api private
        module LogCapture

          extend self

          # @yield runs with a temporary logger writing to an in-memory buffer
          # @return [Array<String>] captured log lines without trailing newlines
          # @raise [ArgumentError] when no block is given
          def capture
            raise ArgumentError, "block required" unless block_given?

            io = StringIO.new
            previous = CMDx.configuration.logger
            formatter = previous&.formatter || CMDx::LogFormatters::Line.new

            CMDx.configuration.logger = Logger.new(io, formatter:)
            yield
            io.string.lines.map(&:chomp)
          ensure
            CMDx.configuration.logger = previous if previous
          end

        end
      end
    end
  end
end
