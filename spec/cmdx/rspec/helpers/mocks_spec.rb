# frozen_string_literal: true

require "spec_helper"

RSpec.describe CMDx::RSpec::Helpers::Mocks do
  let(:task_class) { create_task_class(name: "TestTask") }

  describe "#expect_execute" do
    context "when command receives execute with matching context" do
      it "passes" do
        expect_execute(task_class, foo: "bar")

        task_class.execute(foo: "bar")
      end

      it "passes with empty context" do
        expect_execute(task_class)

        task_class.execute
      end
    end
  end

  describe "#expect_execute!" do
    context "when command receives execute! with matching context" do
      it "passes" do
        expect_execute!(task_class, foo: "bar")

        task_class.execute!(foo: "bar")
      end

      it "passes with empty context" do
        expect_execute!(task_class)

        task_class.execute!
      end
    end
  end
end
