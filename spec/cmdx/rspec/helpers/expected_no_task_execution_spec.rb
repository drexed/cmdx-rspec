# frozen_string_literal: true

require "spec_helper"

RSpec.describe "CMDx::RSpec::Helpers expected_no_task_execution" do
  let(:task_class) { create_task_class(name: "TestTask") }

  before do
    allow(task_class).to receive(:execute)
    allow(task_class).to receive(:execute!)
  end

  describe "#expected_no_task_execution" do
    context "when command did not receive execute" do
      it "passes" do
        expected_no_task_execution(task_class)
      end
    end
  end

  describe "#expected_no_task_execution!" do
    context "when command did not receive execute!" do
      it "passes" do
        expected_no_task_execution!(task_class)
      end
    end
  end
end
