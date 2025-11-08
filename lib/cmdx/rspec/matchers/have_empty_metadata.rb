# frozen_string_literal: true

# Matcher to verify that a result has empty metadata.
#
# @param result [CMDx::Result] The result to check
#
# @return [RSpec::Matchers::BuiltIn::BaseMatcher] The matcher instance
#
# @raise [ArgumentError] if the actual value is not a CMDx::Result
#
# @example Checking if a result has empty metadata
#   result = MyCommand.execute
#   expect(result).to have_empty_metadata
RSpec::Matchers.define :have_empty_metadata do
  description { "have an empty metadata" }

  match(notify_expectation_failures: true) do |result|
    raise ArgumentError, "must be a CMDx::Result" unless result.is_a?(CMDx::Result)

    expect(result.to_h[:metadata]).to be_empty
  end
end
