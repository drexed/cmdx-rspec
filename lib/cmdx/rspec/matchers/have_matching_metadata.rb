# frozen_string_literal: true

# Matcher to verify that a result's metadata matches the given data.
#
# @param data [Hash] Optional hash of key-value pairs to match in the metadata
#   If empty, delegates to {have_empty_metadata}
#
# @param result [CMDx::Result] The result to check
#
# @return [RSpec::Matchers::BuiltIn::BaseMatcher] The matcher instance
#
# @raise [ArgumentError] if the actual value is not a CMDx::Result
#
# @example Checking metadata matches specific values
#   result = MyCommand.execute
#   expect(result).to have_matching_metadata(key: "value", count: 42)
#
# @example Checking empty metadata
#   result = MyCommand.execute
#   expect(result).to have_matching_metadata
RSpec::Matchers.define :have_matching_metadata do |**data|
  description { "have matching metadata" }

  match(notify_expectation_failures: true) do |result|
    raise ArgumentError, "must be a CMDx::Result" unless result.is_a?(CMDx::Result)

    if data.empty?
      expect(result).to have_empty_metadata
    else
      expect(result.to_h[:metadata]).to include(**data)
    end
  end
end
