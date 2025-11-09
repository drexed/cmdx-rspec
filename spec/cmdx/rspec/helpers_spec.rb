# frozen_string_literal: true

require "spec_helper"

RSpec.describe CMDx::RSpec::Helpers do
  let(:task_class) { create_task_class(name: "TestTask") }

  describe "#stub_task_success" do
    context "when stubbing execute" do
      it "returns successful result" do
        stub_task_success(task_class, foo: "bar")

        result = task_class.execute(foo: "bar")

        expect(result).to be_successful
      end

      it "returns successful result with empty context" do
        stub_task_success(task_class)

        result = task_class.execute

        expect(result).to be_successful
      end
    end
  end

  describe "#stub_task_success!" do
    context "when stubbing execute!" do
      it "returns successful result" do
        stub_task_success!(task_class, foo: "bar")

        result = task_class.execute!(foo: "bar")

        expect(result).to be_successful
      end

      it "returns successful result with empty context" do
        stub_task_success!(task_class)

        result = task_class.execute!

        expect(result).to be_successful
      end
    end
  end

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

  describe "#unstub_task" do
    context "when unstubbing execute" do
      it "restores original behavior after stubbing" do
        original_task = create_successful_task(name: "OriginalTask")
        stub_task_success(original_task, foo: "bar")

        result = original_task.execute(foo: "bar")
        expect(result).to be_successful
        expect(result.context.executed).to be_nil

        unstub_task(original_task)

        result = original_task.execute(foo: "bar")
        expect(result).to be_successful
        expect(result.context.executed).to eq([:success])
      end

      it "restores original behavior after stubbing with empty context" do
        original_task = create_successful_task(name: "OriginalTask")
        stub_task_success(original_task)

        result = original_task.execute
        expect(result).to be_successful
        expect(result.context.executed).to be_nil

        unstub_task(original_task)

        result = original_task.execute
        expect(result).to be_successful
        expect(result.context.executed).to eq([:success])
      end
    end
  end

  describe "#unstub_task!" do
    context "when unstubbing execute!" do
      it "restores original behavior after stubbing" do
        original_task = create_successful_task(name: "OriginalTask")
        stub_task_success!(original_task, foo: "bar")

        result = original_task.execute!(foo: "bar")
        expect(result).to be_successful
        expect(result.context.executed).to be_nil

        unstub_task!(original_task)

        result = original_task.execute!(foo: "bar")
        expect(result).to be_successful
        expect(result.context.executed).to eq([:success])
      end

      it "restores original behavior after stubbing with empty context" do
        original_task = create_successful_task(name: "OriginalTask")
        stub_task_success!(original_task)

        result = original_task.execute!
        expect(result).to be_successful
        expect(result.context.executed).to be_nil

        unstub_task!(original_task)

        result = original_task.execute!
        expect(result).to be_successful
        expect(result.context.executed).to eq([:success])
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
