# frozen_string_literal: true

require "spec_helper"

RSpec.describe "CMDx::RSpec::Helpers stub_workflow_tasks" do
  let(:task_class) { create_task_class(name: "TestTask") }

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
