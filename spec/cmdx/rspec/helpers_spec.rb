# frozen_string_literal: true

require "spec_helper"

RSpec.describe CMDx::RSpec::Helpers do
  let(:task_class) { create_task_class(name: "TestTask") }

  describe "#stub_task_success" do
    context "when stubbing execute" do
      it "returns successful result" do
        stub_task_success(task_class, foo: "bar")

        result = task_class.execute(foo: "bar")

        expect(result).to have_been_success
      end

      it "returns successful result with empty context" do
        stub_task_success(task_class)

        result = task_class.execute

        expect(result).to have_been_success
      end
    end
  end

  describe "#stub_task_success!" do
    context "when stubbing execute!" do
      it "returns successful result" do
        stub_task_success!(task_class, foo: "bar")

        result = task_class.execute!(foo: "bar")

        expect(result).to have_been_success
      end

      it "returns successful result with empty context" do
        stub_task_success!(task_class)

        result = task_class.execute!

        expect(result).to have_been_success
      end
    end
  end

  describe "#stub_task_skip" do
    context "when stubbing execute with skip" do
      it "returns skipped result" do
        stub_task_skip(task_class, foo: "bar")

        result = task_class.execute(foo: "bar")

        expect(result).to have_been_skipped
      end

      it "returns skipped result with reason" do
        reason = "Skipped for testing"

        stub_task_skip(task_class, reason:, foo: "bar")

        result = task_class.execute(foo: "bar")

        expect(result).to have_been_skipped(reason:)
      end

      it "returns skipped result with empty context" do
        stub_task_skip(task_class)

        result = task_class.execute

        expect(result).to have_been_skipped
      end
    end
  end

  describe "#stub_task_skip!" do
    context "when stubbing execute! with skip" do
      it "returns skipped result" do
        stub_task_skip!(task_class, foo: "bar")

        result = task_class.execute!(foo: "bar")

        expect(result).to have_been_skipped
      end

      it "returns skipped result with reason" do
        reason = "Skipped for testing"

        stub_task_skip!(task_class, reason:, foo: "bar")

        result = task_class.execute!(foo: "bar")

        expect(result).to have_been_skipped(reason:)
      end

      it "returns skipped result with empty context" do
        stub_task_skip!(task_class)

        result = task_class.execute!

        expect(result).to have_been_skipped
      end
    end
  end

  describe "#stub_task_fail" do
    context "when stubbing execute with failure" do
      it "returns failed result" do
        stub_task_fail(task_class, foo: "bar")

        result = task_class.execute(foo: "bar")

        expect(result).to have_been_failure
      end

      it "returns failed result with reason" do
        reason = "Failed for testing"

        stub_task_fail(task_class, reason:, foo: "bar")

        result = task_class.execute(foo: "bar")

        expect(result).to have_been_failure(reason:)
      end

      it "returns failed result with empty context" do
        stub_task_fail(task_class)

        result = task_class.execute

        expect(result).to have_been_failure
      end
    end
  end

  describe "#stub_task_fail!" do
    context "when stubbing execute! with failure" do
      it "returns failed result" do
        stub_task_fail!(task_class, foo: "bar")

        result = task_class.execute!(foo: "bar")

        expect(result).to have_been_failure
      end

      it "returns failed result with reason" do
        reason = "Failed for testing"

        stub_task_fail!(task_class, reason:, foo: "bar")

        result = task_class.execute!(foo: "bar")

        expect(result).to have_been_failure(reason:)
      end

      it "returns failed result with empty context" do
        stub_task_fail!(task_class)

        result = task_class.execute!

        expect(result).to have_been_failure
      end
    end
  end

  describe "#expect_task_execution" do
    context "when command receives execute with matching context" do
      it "passes" do
        expect_task_execution(task_class, foo: "bar")

        task_class.execute(foo: "bar")
      end

      it "passes with empty context" do
        expect_task_execution(task_class)

        task_class.execute
      end
    end
  end

  describe "#expect_task_execution!" do
    context "when command receives execute! with matching context" do
      it "passes" do
        expect_task_execution!(task_class, foo: "bar")

        task_class.execute!(foo: "bar")
      end

      it "passes with empty context" do
        expect_task_execution!(task_class)

        task_class.execute!
      end
    end
  end
end
