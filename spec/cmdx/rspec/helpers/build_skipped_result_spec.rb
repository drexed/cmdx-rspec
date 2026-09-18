# frozen_string_literal: true

require "spec_helper"

RSpec.describe "CMDx::RSpec::Helpers build_skipped_result" do
  let(:snapshot) { { id: 1, state: "ready" } }

  describe "#build_skipped_result" do
    it "returns a skipped result with reason" do
      result = build_skipped_result(reason: "not applicable", snapshot:)

      expect(result).to have_skipped(reason: "not applicable")
      expect(result).to have_matching_context(snapshot:)
    end
  end
end
