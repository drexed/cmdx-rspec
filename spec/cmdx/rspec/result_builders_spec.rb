# frozen_string_literal: true

require "spec_helper"

RSpec.describe "CMDx::RSpec result builders" do
  let(:task_class) { create_task_class(name: "BuilderTask") }
  let(:snapshot) { { id: 1, state: "ready" } }

  describe "#build_successful_result" do
    it "returns a result matchers recognize as successful" do
      result = build_successful_result(snapshot:)

      expect(result).to be_successful
      expect(result).to have_matching_context(snapshot:)
      expect(result.ctx.snapshot).to eq(snapshot)
    end

    it "exposes metadata on the result" do
      result = build_successful_result(metadata: { id: 1 })

      expect(result).to be_successful(metadata: { id: 1 })
    end

    it "uses the supplied task class for result.task" do
      result = build_successful_result(task: task_class)

      expect(result.task).to eq(task_class)
    end
  end

  describe "#build_skipped_result" do
    it "returns a skipped result with reason" do
      result = build_skipped_result(reason: "not applicable", snapshot:)

      expect(result).to have_skipped(reason: "not applicable")
      expect(result).to have_matching_context(snapshot:)
    end
  end

  describe "#build_failed_result" do
    it "returns a failed result with reason and cause" do
      cause = CMDx::TestError.new("boom")
      result = build_failed_result(reason: "failed", cause:, snapshot:)

      expect(result).to have_failed(reason: "failed", cause:)
      expect(result).to have_matching_context(snapshot:)
    end
  end

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
