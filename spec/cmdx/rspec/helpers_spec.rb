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

  describe "#stub_workflow_tasks" do
    it "raises when no block is given" do
      workflow = create_successful_workflow(name: "NoBlockWorkflow")

      expect { stub_workflow_tasks(workflow) }.to raise_error(ArgumentError, "block required")
    end

    it "raises when command is not a workflow" do
      expect { stub_workflow_tasks(task_class) { |_t| nil } }
        .to raise_error(ArgumentError, "#{task_class.inspect} must be a workflow")
    end

    it "yields each distinct task class in pipeline order and returns the deduplicated list" do
      first = create_successful_task(name: "StubWorkflowTask1")
      second = create_successful_task(name: "StubWorkflowTask2")
      workflow = create_workflow_class(name: "OrderedStubWorkflow") do
        tasks first, second, first
      end

      seen = []
      returned = stub_workflow_tasks(workflow) { |t| seen << t }

      expect(seen).to eq([first, second])
      expect(returned).to eq([first, second])
    end

    it "concatenates tasks across pipeline stages before deduplicating" do
      stage_one = create_successful_task(name: "StubStageOneTask")
      stage_two = create_successful_task(name: "StubStageTwoTask")
      workflow = create_workflow_class(name: "MultiStageStubWorkflow") do
        tasks stage_one
        tasks stage_two, stage_one
      end

      returned = stub_workflow_tasks(workflow) { |_t| nil }

      expect(returned).to eq([stage_one, stage_two])
    end
  end
end
