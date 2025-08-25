# frozen_string_literal: true

require "spec_helper"

RSpec.describe "have_been_skipped matcher" do
  describe "basic skipped checking" do
    context "when result is a skipped" do
      it "passes" do
        task_class = create_skipping_task(name: "TestTask")
        result = task_class.execute(CMDx::Context.new)

        expect(result).to have_been_skipped
      end
    end
  end

  describe "skipped attributes validation" do
    context "with default skipped result" do
      let(:task_class) { create_skipping_task(name: "TestTask") }
      let(:result) { task_class.execute(CMDx::Context.new) }

      it "validates all required skipped attributes" do
        expect(result).to have_been_skipped
      end

      it "validates state is INTERRUPTED" do
        expect(result).to have_been_skipped(state: CMDx::Result::INTERRUPTED)
      end

      it "validates status is SKIPPED" do
        expect(result).to have_been_skipped(status: CMDx::Result::SKIPPED)
      end

      it "validates cause is a SkipFault" do
        expect(result).to have_been_skipped(cause: be_a(CMDx::SkipFault))
      end
    end
  end

  describe "edge cases" do
    context "with non-CMDx::Result input" do
      it "raises ArgumentError for string" do
        expect { expect("not a result").to have_been_skipped }.to raise_error(ArgumentError, "must be a CMDx::Result")
      end

      it "raises ArgumentError for nil" do
        expect { expect(nil).to have_been_skipped }.to raise_error(ArgumentError, "must be a CMDx::Result")
      end

      it "raises ArgumentError for arbitrary object" do
        expect { expect(Object.new).to have_been_skipped }.to raise_error(ArgumentError, "must be a CMDx::Result")
      end
    end
  end

  describe "matcher description" do
    it "provides clear description" do
      expect(have_been_skipped.description).to eq("have been skipped")
    end
  end
end
