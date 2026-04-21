# frozen_string_literal: true

# Matcher to verify a {CMDx::Result}'s duration (in milliseconds) falls
# within an upper bound, lower bound, or both.
#
# @example
#   expect(result).to have_duration(less_than: 100)
#   expect(result).to have_duration(greater_than: 0.1)
#   expect(result).to have_duration(greater_than: 1, less_than: 50)
RSpec::Matchers.define :have_duration do |less_than: nil, greater_than: nil|
  description do
    parts = []
    parts << "greater than #{greater_than}ms" if greater_than
    parts << "less than #{less_than}ms" if less_than
    "have duration #{parts.join(' and ')}"
  end

  failure_message do |result|
    "expected duration to satisfy bounds (less_than: #{less_than}, greater_than: #{greater_than}), but was #{result.duration}"
  end

  match do |result|
    raise ArgumentError, "must be a CMDx::Result" unless result.is_a?(CMDx::Result)
    raise ArgumentError, "provide :less_than and/or :greater_than" if less_than.nil? && greater_than.nil?
    next false if result.duration.nil?

    (less_than.nil? || result.duration < less_than) &&
      (greater_than.nil? || result.duration > greater_than)
  end
end
