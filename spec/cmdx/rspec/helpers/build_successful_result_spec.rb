# frozen_string_literal: true

require "spec_helper"

RSpec.describe "CMDx::RSpec::Helpers build_successful_result" do
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
end
