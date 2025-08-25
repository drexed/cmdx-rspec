# frozen_string_literal: true

require "spec_helper"

RSpec.describe "have_been_success matcher" do
  describe "basic success checking" do
    context "when result is a success" do
      it "passes" do
        task_class = create_successful_task(name: "TestTask")
        result = task_class.execute(CMDx::Context.new)

        expect(result).to have_been_success
      end
    end
  end

  describe "success attributes validation" do
    context "with default success result" do
      let(:task_class) { create_successful_task(name: "TestTask") }
      let(:result) { task_class.execute(CMDx::Context.new) }

      it "validates all required success attributes" do
        expect(result).to have_been_success
      end

      it "validates state is COMPLETE" do
        expect(result).to have_been_success(state: CMDx::Result::COMPLETE)
      end

      it "validates status is SUCCESS" do
        expect(result).to have_been_success(status: CMDx::Result::SUCCESS)
      end
    end
  end

  describe "edge cases" do
    context "with non-CMDx::Result input" do
      it "raises ArgumentError for string" do
        expect { expect("not a result").to have_been_success }.to raise_error(ArgumentError, "must be a CMDx::Result")
      end

      it "raises ArgumentError for nil" do
        expect { expect(nil).to have_been_success }.to raise_error(ArgumentError, "must be a CMDx::Result")
      end

      it "raises ArgumentError for arbitrary object" do
        expect { expect(Object.new).to have_been_success }.to raise_error(ArgumentError, "must be a CMDx::Result")
      end
    end
  end

  describe "matcher description" do
    it "provides clear description" do
      expect(have_been_success.description).to eq("have been a success")
    end
  end
end
