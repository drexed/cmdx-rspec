# frozen_string_literal: true

# Matcher to verify that a result completed without interruption.
#
# @example
#   expect(MyCommand.execute).to be_complete
RSpec::Matchers.define :be_complete do
  description { "have completed" }

  failure_message do |result|
    "expected #{result.inspect} to have state #{CMDx::Signal::COMPLETE.inspect}, " \
      "but was #{result.state.inspect}"
  end

  match do |result|
    raise ArgumentError, "must be a CMDx::Result" unless result.is_a?(CMDx::Result)

    result.state == CMDx::Signal::COMPLETE
  end
end
