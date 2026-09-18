# frozen_string_literal: true

require "spec_helper"

RSpec.describe "CMDx::RSpec::Helpers unstub_task" do
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
end
