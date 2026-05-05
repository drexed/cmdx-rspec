# frozen_string_literal: true

# Matcher to verify that a result was interrupted (skipped or failed).
#
# @example
#   expect(MyCommand.execute).to be_interrupted
RSpec::Matchers.define :be_interrupted do
  description { "have been interrupted" }

  failure_message do |result|
    "expected #{result.inspect} to have state #{CMDx::Signal::INTERRUPTED.inspect}, " \
      "but was #{result.state.inspect}"
  end

  match do |result|
    raise ArgumentError, "must be a CMDx::Result" unless result.is_a?(CMDx::Result)

    result.state == CMDx::Signal::INTERRUPTED
  end
end
