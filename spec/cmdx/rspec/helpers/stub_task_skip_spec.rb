# frozen_string_literal: true

require "spec_helper"

RSpec.describe "CMDx::RSpec::Helpers stub_task_skip" do
  let(:task_class) { create_task_class(name: "TestTask") }

  describe "#stub_task_skip" do
    context "when stubbing execute with skip" do
      it "returns skipped result" do
        stub_task_skip(task_class, foo: "bar")

        result = task_class.execute(foo: "bar")

        expect(result).to have_skipped
      end

      it "returns skipped result with reason" do
        reason = "Skipped for testing"

        stub_task_skip(task_class, reason:, foo: "bar")

        result = task_class.execute(foo: "bar")

        expect(result).to have_skipped(reason:)
      end

      it "returns skipped result with empty context" do
        stub_task_skip(task_class)

        result = task_class.execute

        expect(result).to have_skipped
      end
    end
  end

  describe "#stub_task_skip!" do
    context "when stubbing execute! with skip" do
      it "returns skipped result" do
        stub_task_skip!(task_class, foo: "bar")

        result = task_class.execute!(foo: "bar")

        expect(result).to have_skipped
      end

      it "returns skipped result with reason" do
        reason = "Skipped for testing"

        stub_task_skip!(task_class, reason:, foo: "bar")

        result = task_class.execute!(foo: "bar")

        expect(result).to have_skipped(reason:)
      end

      it "returns skipped result with empty context" do
        stub_task_skip!(task_class)

        result = task_class.execute!

        expect(result).to have_skipped
      end
    end
  end
end
