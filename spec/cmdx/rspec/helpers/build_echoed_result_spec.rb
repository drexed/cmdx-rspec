# frozen_string_literal: true

require "spec_helper"

RSpec.describe "CMDx::RSpec::Helpers build_echoed_result" do
  describe "#build_echoed_result" do
    it "echoes an upstream failed result" do
      upstream = build_failed_result(reason: "kaboom")
      result = build_echoed_result(upstream)

      expect(result).to have_failed
      expect(result.origin).to equal(upstream)
    end

    it "raises when given a non-failed result" do
      ok = build_successful_result

      expect { build_echoed_result(ok) }.to raise_error(ArgumentError, "upstream_result must be a failed CMDx::Result")
    end
  end
end
