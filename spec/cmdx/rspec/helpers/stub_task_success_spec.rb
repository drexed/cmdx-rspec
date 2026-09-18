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
