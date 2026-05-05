# frozen_string_literal: true

# Asserts a {CMDx::Result}'s `metadata` hash includes the supplied
# keys/values. With no keyword args, delegates to {have_empty_metadata}.
# Raises `ArgumentError` when the subject is not a Result.
#
# @example
#   expect(result).to have_matching_metadata(status_code: 500)
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
