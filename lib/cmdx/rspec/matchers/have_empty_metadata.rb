# frozen_string_literal: true

# Asserts a {CMDx::Result}'s `metadata` hash is empty. Raises
# `ArgumentError` when the subject is not a Result.
#
# @example
#   expect(result).to have_empty_metadata
RSpec::Matchers.define :have_empty_metadata do
  description { "have an empty metadata" }

  match(notify_expectation_failures: true) do |result|
    raise ArgumentError, "must be a CMDx::Result" unless result.is_a?(CMDx::Result)

    expect(result.to_h[:metadata]).to be_empty
  end
end
