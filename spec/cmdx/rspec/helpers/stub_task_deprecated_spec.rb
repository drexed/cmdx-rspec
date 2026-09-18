# frozen_string_literal: true

require "spec_helper"

RSpec.describe "CMDx::RSpec::Helpers stub_task_deprecated" do
  let(:task_class) { create_task_class(name: "NewHelperTask") }

  describe "#stub_task_deprecated" do
    it "marks the result as deprecated" do
      stub_task_deprecated(task_class)
      result = task_class.execute
      expect(result).to be_successful
      expect(result.deprecated?).to be(true)
    end
  end
end
