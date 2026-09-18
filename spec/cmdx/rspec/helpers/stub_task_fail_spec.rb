# frozen_string_literal: true

require "spec_helper"

RSpec.describe "CMDx::RSpec::Helpers stub_task_fail" do
  let(:task_class) { create_task_class(name: "TestTask") }

  describe "#stub_task_fail" do
    context "when stubbing execute with failure" do
      it "returns failed result" do
        stub_task_fail(task_class, foo: "bar")

        result = task_class.execute(foo: "bar")

        expect(result).to have_failed
      end

      it "returns failed result with reason" do
        reason = "Failed for testing"

        stub_task_fail(task_class, reason:, foo: "bar")

        result = task_class.execute(foo: "bar")

        expect(result).to have_failed(reason:)
      end

      it "returns failed result with empty context" do
        stub_task_fail(task_class)

        result = task_class.execute

        expect(result).to have_failed
      end
    end
  end

  describe "#stub_task_fail!" do
    context "when stubbing execute! with failure" do
      it "returns failed result" do
        stub_task_fail!(task_class, foo: "bar")

        result = task_class.execute!(foo: "bar")

        expect(result).to have_failed
      end

      it "returns failed result with reason" do
        reason = "Failed for testing"

        stub_task_fail!(task_class, reason:, foo: "bar")

        result = task_class.execute!(foo: "bar")

        expect(result).to have_failed(reason:)
      end

      it "returns failed result with empty context" do
        stub_task_fail!(task_class)

        result = task_class.execute!

        expect(result).to have_failed
      end
    end
  end
end
