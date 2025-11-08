# frozen_string_literal: true

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
