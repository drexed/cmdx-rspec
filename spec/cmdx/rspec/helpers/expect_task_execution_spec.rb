# frozen_string_literal: true

require "spec_helper"

RSpec.describe "CMDx::RSpec::Helpers expect_task_execution" do
  let(:task_class) { create_task_class(name: "TestTask") }

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
