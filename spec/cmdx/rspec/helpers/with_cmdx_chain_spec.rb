# frozen_string_literal: true

require "spec_helper"

RSpec.describe "CMDx::RSpec::Helpers with_cmdx_chain" do
  describe "#with_cmdx_chain" do
    it "captures the chain produced by command's execution" do
      cmd = create_successful_task(name: "ChainTask")
      chain = with_cmdx_chain(cmd) { cmd.execute(CMDx::Context.new) }
      expect(chain).to be_a(CMDx::Chain)
      expect(chain.size).to eq(1)
    end

    it "returns nil when no root execution happened" do
      cmd = create_successful_task(name: "ChainTaskNone")
      expect(with_cmdx_chain(cmd) { :noop }).to be_nil
    end
  end
end
