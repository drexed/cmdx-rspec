# frozen_string_literal: true

require "spec_helper"

RSpec.describe "CMDx::RSpec::Helpers build_result" do
  let(:snapshot) { { id: 1, state: "ready" } }

  describe "#build_result" do
    it "accepts a pre-built signal" do
      signal = CMDx::Signal.success("done", metadata: { rows: 2 })
      result = build_result(signal, snapshot:)

      expect(result).to be_successful(reason: "done", metadata: { rows: 2 })
    end

    it "joins an existing chain" do
      chain = CMDx::Chain.new
      first = build_result(:success, chain:)
      second = build_result(:success, chain:)

      expect(chain.size).to eq(2)
      expect(second.chain).to equal(chain)
      expect(first.chain).to equal(chain)
    end

    it "accepts an explicit CMDx::Context" do
      ctx = CMDx::Context.new(snapshot:)

      result = build_result(:success, context: ctx)

      expect(result).to have_matching_context(snapshot:)
    end

    it "forwards lifecycle options" do
      result = build_result(:success, strict: true, deprecated: true, retries: 2, rolled_back: true)

      expect(result.strict?).to be(true)
      expect(result.deprecated?).to be(true)
      expect(result.retries).to eq(2)
      expect(result.rolled_back?).to be(true)
    end

    it "raises for unknown statuses" do
      expect { build_result(:unknown) }.to raise_error(ArgumentError, /unknown result status/)
    end
  end
end
