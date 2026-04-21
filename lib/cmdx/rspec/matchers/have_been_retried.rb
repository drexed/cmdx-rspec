# frozen_string_literal: true

# Matcher to verify that a result was retried at least once, optionally
# matching a specific retry count.
#
# @example Any retry
#   expect(result).to have_been_retried
#
# @example Exact retry count
#   expect(result).to have_been_retried(3)
RSpec::Matchers.define :have_been_retried do |expected_count = nil|
  description do
    expected_count ? "have been retried #{expected_count} times" : "have been retried"
  end

  failure_message do |result|
    if expected_count
      "expected #{result.inspect} to have been retried #{expected_count} times, but it was #{result.retries}"
    else
      "expected #{result.inspect} to have been retried, but it wasn't"
    end
  end

  failure_message_when_negated do |result|
    if expected_count
      "expected #{result.inspect} not to have been retried #{expected_count} times, but it was"
    else
      "expected #{result.inspect} not to have been retried, but it was retried #{result.retries} times"
    end
  end

  match do |result|
    raise ArgumentError, "must be a CMDx::Result" unless result.is_a?(CMDx::Result)

    if expected_count.nil?
      result.retried?
    else
      result.retries == expected_count
    end
  end
end
