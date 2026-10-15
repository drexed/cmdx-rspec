# frozen_string_literal: true

require "spec_helper"

RSpec.describe "execute_pipeline matcher" do
  let(:task_class) { create_task_class(name: "PipelineMatcherTask") }

  describe "description" do
    it "describes the pipeline target and shared execute configuration" do
      expect(execute_pipeline.and_succeed.description).to eq("execute_pipeline and succeed on instances")
      expect(execute_pipeline.on_class.and_fail(reason: "nope").description)
        .to eq('execute_pipeline and fail with reason "nope" on class')
    end
  end

  describe "allow" do
    it "raises when the subject is not a workflow" do
      expect { allow(task_class).to execute_pipeline.and_succeed }
        .to raise_error(ArgumentError, "#{task_class.inspect} must be a workflow")
    end

    it "stubs instance execute for every distinct pipeline task when a workflow runs" do
      ran = []
      first = create_task_class(name: "PipelineStubTask1") do
        define_method(:work) { ran << :first }
      end
      second = create_task_class(name: "PipelineStubTask2") do
        define_method(:work) { ran << :second }
      end
      workflow = create_workflow_class(name: "PipelineStubWorkflow") do
        tasks first, second, first
      end

      allow(workflow).to execute_pipeline.and_succeed

      expect(workflow.execute).to be_ok
      expect(ran).to be_empty
    end

    it "applies a shared failure outcome to every pipeline task" do
      failing = create_failing_task(name: "PipelineFailTask", reason: "unused")
      workflow = create_workflow_class(name: "PipelineFailWorkflow") { tasks failing }

      allow(workflow).to execute_pipeline.and_fail(reason: "nope")

      result = workflow.execute

      expect(result).to be_ko
      expect(result.reason).to eq("nope")
    end

    it "applies per-task execute matchers from a block" do
      succeeding = create_successful_task(name: "PipelineSucceedTask")
      failing = create_failing_task(name: "PipelineFailTask", reason: "unused")
      workflow = create_workflow_class(name: "PipelineMixedWorkflow") do
        tasks succeeding, failing
      end

      allow(workflow).to(
        execute_pipeline do |task|
          task == failing ? execute.and_fail(reason: "nope") : execute.and_succeed
        end
      )

      result = workflow.execute

      expect(result).to be_ko
      expect(result.reason).to eq("nope")
    end

    it "raises when the per-task block returns an invalid value" do
      workflow = create_successful_workflow(name: "PipelineInvalidBlockWorkflow")

      expect do
        allow(workflow).to(execute_pipeline { |_task| :nope })
      end.to raise_error(ArgumentError, "block must return an `execute` matcher or nil")
    end

    context "when targeting class execute" do
      it "stubs Task.execute for pipeline tasks" do
        inner = create_successful_task(name: "PipelineClassTargetTask")
        workflow = create_workflow_class(name: "PipelineClassWorkflow") { tasks inner }

        allow(workflow).to execute_pipeline.on_class.and_succeed(metadata: { class_stub: true })

        expect(inner.execute).to be_successful(metadata: { class_stub: true })
      end
    end
  end

  describe "expect" do
    it "requires every pipeline task instance to execute when the workflow runs" do
      inner = create_successful_task(name: "PipelineExpectTask")
      workflow = create_workflow_class(name: "PipelineExpectWorkflow") { tasks inner }

      expect(workflow).to execute_pipeline.and_succeed

      workflow.execute
    end
  end

  describe "unsupported any_instance targets" do
    it "raises for allow_any_instance_of" do
      workflow = create_successful_workflow(name: "PipelineAnyInstanceWorkflow")

      expect { allow_any_instance_of(workflow).to execute_pipeline.and_succeed } # rubocop:disable RSpec/AnyInstance
        .to raise_error(ArgumentError, /allow_any_instance_of/)
    end
  end
end
