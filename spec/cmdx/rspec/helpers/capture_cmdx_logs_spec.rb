# frozen_string_literal: true

require "spec_helper"

RSpec.describe "CMDx::RSpec::Helpers capture_cmdx_logs" do
  describe "#capture_cmdx_logs" do
    it "captures lines emitted within the block" do
      lines = capture_cmdx_logs do
        CMDx.configuration.logger.info("hello world")
      end
      expect(lines.join).to include("hello world")
    end

    it "restores the original logger" do
      original = CMDx.configuration.logger
      capture_cmdx_logs { :noop }
      expect(CMDx.configuration.logger).to equal(original)
    end

    it "raises without a block" do
      expect { capture_cmdx_logs }.to raise_error(ArgumentError)
    end
  end
end
