# frozen_string_literal: true

require "spec_helper"

RSpec.describe "CMDx::RSpec::Helpers expect_no_task_execution" do
  let(:task_class) { create_task_class(name: "TestTask") }

  describe "#expect_no_task_execution" do
    context "when command does not receive execute" do
      it "passes" do
        expect_no_task_execution(task_class)
      end
    end
  end

  describe "#expect_no_task_execution!" do
    context "when command does not receive execute!" do
      it "passes" do
        expect_no_task_execution!(task_class)
      end
    end
  end
end
