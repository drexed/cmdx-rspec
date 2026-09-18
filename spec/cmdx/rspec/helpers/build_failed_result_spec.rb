# frozen_string_literal: true

require "spec_helper"

RSpec.describe "CMDx::RSpec::Helpers build_failed_result" do
  let(:snapshot) { { id: 1, state: "ready" } }

  describe "#build_failed_result" do
    it "returns a failed result with reason and cause" do
      cause = CMDx::TestError.new("boom")
      result = build_failed_result(reason: "failed", cause:, snapshot:)

      expect(result).to have_failed(reason: "failed", cause:)
      expect(result).to have_matching_context(snapshot:)
    end
  end
end
