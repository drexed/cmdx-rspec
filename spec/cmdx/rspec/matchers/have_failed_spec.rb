# frozen_string_literal: true

require "spec_helper"

RSpec.describe "have_failed matcher" do
  describe "basic failure checking" do
    context "when result is a failure" do
      it "passes" do
        task_class = create_failing_task(name: "TestTask")
        result = task_class.execute(CMDx::Context.new)

        expect(result).to have_failed
      end
    end
  end

  describe "failure attributes validation" do
    context "with default failure result" do
      let(:task_class) { create_failing_task(name: "TestTask") }
      let(:result) { task_class.execute(CMDx::Context.new) }

      it "validates all required failure attributes" do
        expect(result).to have_failed
      end

      it "validates state is INTERRUPTED" do
        expect(result).to have_failed(state: CMDx::Result::INTERRUPTED)
      end

      it "validates status is FAILED" do
        expect(result).to have_failed(status: CMDx::Result::FAILED)
      end

      it "validates cause is a FailFault" do
        expect(result).to have_failed(cause: be_a(CMDx::FailFault))
      end
    end
  end

  describe "edge cases" do
    context "with non-CMDx::Result input" do
      it "raises ArgumentError for string" do
        expect { expect("not a result").to have_failed }.to raise_error(ArgumentError, "must be a CMDx::Result")
      end

      it "raises ArgumentError for nil" do
        expect { expect(nil).to have_failed }.to raise_error(ArgumentError, "must be a CMDx::Result")
      end

      it "raises ArgumentError for arbitrary object" do
        expect { expect(Object.new).to have_failed }.to raise_error(ArgumentError, "must be a CMDx::Result")
      end
    end
  end

  describe "matcher description" do
    it "provides clear description" do
      expect(have_failed.description).to eq("have been a failure")
    end
  end
end
