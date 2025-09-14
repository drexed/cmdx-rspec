# frozen_string_literal: true

RSpec::Matchers.define :have_empty_metadata do
  description { "have an empty metadata" }

  match(notify_expectation_failures: true) do |result|
    raise ArgumentError, "must be a CMDx::Result" unless result.is_a?(CMDx::Result)

    expect(result.to_h[:metadata]).to be_empty
  end
end
