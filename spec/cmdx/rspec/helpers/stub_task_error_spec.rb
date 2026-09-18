# frozen_string_literal: true

require "spec_helper"

RSpec.describe "CMDx::RSpec::Helpers stub_task_error" do
  let(:task_class) { create_task_class(name: "NewHelperTask") }

  describe "#stub_task_error" do
    it "stubs execute to return failed result with the given exception as cause" do
      stub_task_error(task_class, CMDx::TestError, "boom")
      result = task_class.execute
      expect(result).to have_failed
      expect(result.cause).to be_a(CMDx::TestError)
      expect(result.reason).to include("CMDx::TestError")
    end

    it "accepts an exception instance" do
      ex = CMDx::TestError.new("custom")
      stub_task_error(task_class, ex)
      result = task_class.execute
      expect(result.cause).to equal(ex)
    end
  end
end
