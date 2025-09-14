# frozen_string_literal: true

require "spec_helper"

RSpec.describe "have_empty_metadata matcher" do
  describe "basic empty metadata checking" do
    context "when result has empty metadata" do
      it "passes" do
        task_class = create_task_class(name: "TestTask") do
          define_method(:work) { :success }
        end
        result = task_class.execute(CMDx::Context.new)

        expect(result).to have_empty_metadata
      end
    end
  end

  describe "non-empty metadata validation" do
    context "with result containing metadata" do
      it "fails for result with metadata" do
        task_class = create_skipping_task(name: "TestTask", user_id: 123)
        result = task_class.execute(CMDx::Context.new)

        expect { expect(result).to have_empty_metadata }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end
    end

    context "with result containing multiple metadata entries" do
      it "fails for result with multiple metadata entries" do
        task_class = create_failing_task(name: "TestTask", session_id: "abc123", request_id: "req456")
        result = task_class.execute(CMDx::Context.new)

        expect { expect(result).to have_empty_metadata }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end
    end
  end
end
