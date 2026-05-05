# frozen_string_literal: true

# Matcher to verify that a result is "ok" (success or skipped, anything but failed).
#
# @example
#   expect(MyCommand.execute).to be_ok
RSpec::Matchers.define :be_ok do
  description { "have been ok" }

  failure_message do |result|
    "expected #{result.inspect} to be ok (success or skipped), but status was #{result.status.inspect}"
  end

  match do |result|
    raise ArgumentError, "must be a CMDx::Result" unless result.is_a?(CMDx::Result)

    result.ok?
  end
end
