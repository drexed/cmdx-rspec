# frozen_string_literal: true

require "spec_helper"

RSpec.describe "CMDx::RSpec::Helpers expected_task_execution" do
  let(:task_class) { create_task_class(name: "TestTask") }

  before do
    stub_task_success(task_class)
    stub_task_success!(task_class)
  end

  describe "#expected_task_execution" do
    context "when command received execute with matching context" do
      it "passes" do
        task_class.execute(foo: "bar")

        expected_task_execution(task_class, foo: "bar")
      end

      it "passes with empty context" do
        task_class.execute

        expected_task_execution(task_class)
      end
    end
  end

  describe "#expected_task_execution!" do
    context "when command received execute! with matching context" do
      it "passes" do
        task_class.execute!(foo: "bar")

        expected_task_execution!(task_class, foo: "bar")
      end

      it "passes with empty context" do
        task_class.execute!

        expected_task_execution!(task_class)
      end
    end
  end
end
