# frozen_string_literal: true

# Matcher to verify that a result is "ko" (skipped or failed, anything but success).
#
# @example
#   expect(MyCommand.execute).to be_ko
RSpec::Matchers.define :be_ko do
  description { "have been ko" }

  failure_message do |result|
    "expected #{result.inspect} to be ko (skipped or failed), but status was #{result.status.inspect}"
  end

  match do |result|
    raise ArgumentError, "must be a CMDx::Result" unless result.is_a?(CMDx::Result)

    result.ko?
  end
end
