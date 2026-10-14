# frozen_string_literal: true

require "spec_helper"

RSpec.describe "CMDx::RSpec::Helpers stub_task_success" do
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

      it "uses the stubbed command for result.task" do
        result = stub_task_success(task_class)

        expect(result.task).to eq(task_class)
      end

      it "raises when command is not a Task class" do
        expect { stub_task_success(String) }.to raise_error(ArgumentError, "command must be a Task class")
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
end
