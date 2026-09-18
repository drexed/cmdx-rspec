# frozen_string_literal: true

require "spec_helper"

RSpec.describe "CMDx::RSpec::Helpers stub_task_throw" do
  let(:task_class) { create_task_class(name: "NewHelperTask") }

  describe "#stub_task_throw" do
    it "echoes an upstream failed result" do
      upstream = create_failing_task(reason: "kaboom").execute(CMDx::Context.new)
      stub_task_throw(task_class, upstream)
      result = task_class.execute
      expect(result).to have_failed
      expect(result.origin).to equal(upstream)
    end

    it "raises when given a non-failed result" do
      ok = create_successful_task.execute(CMDx::Context.new)
      expect { stub_task_throw(task_class, ok) }.to raise_error(ArgumentError)
    end
  end
end
