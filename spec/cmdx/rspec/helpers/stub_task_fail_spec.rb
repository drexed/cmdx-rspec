# frozen_string_literal: true

require "spec_helper"

RSpec.describe "CMDx::RSpec::Helpers stub_task_fail" do
  let(:task_class) { create_task_class(name: "TestTask") }

  describe "#stub_task_fail" do
    context "when stubbing execute with failure" do
      it "returns failed result" do
        stub_task_fail(task_class, foo: "bar")

        result = task_class.execute(foo: "bar")

        expect(result).to have_failed
      end

      it "returns failed result with reason" do
        reason = "Failed for testing"

        stub_task_fail(task_class, reason:, foo: "bar")

        result = task_class.execute(foo: "bar")

        expect(result).to have_failed(reason:)
      end

      it "returns failed result with empty context" do
        stub_task_fail(task_class)

        result = task_class.execute

        expect(result).to have_failed
      end
    end
  end

  describe "#stub_task_fail!" do
    context "when stubbing execute! with failure" do
      it "raises CMDx::Fault" do
        stub_task_fail!(task_class, foo: "bar")

        expect { task_class.execute!(foo: "bar") }.to raise_cmdx_fault(task_class)
      end

      it "raises CMDx::Fault with reason" do
        reason = "Failed for testing"

        stub_task_fail!(task_class, reason:, foo: "bar")

        expect { task_class.execute!(foo: "bar") }.to raise_cmdx_fault(task_class).with_reason(reason)
      end

      it "raises CMDx::Fault with empty context" do
        stub_task_fail!(task_class)

        expect { task_class.execute! }.to raise_cmdx_fault(task_class)
      end

      it "re-raises cause when given" do
        cause = NoMethodError.new("boom")

        stub_task_fail!(task_class, cause:)

        expect { task_class.execute! }.to raise_error(cause)
      end

      it "returns the backing failed result from the helper" do
        reason = "Failed for testing"

        result = stub_task_fail!(task_class, reason:)

        expect(result).to have_failed(reason:)
        expect(result.strict?).to be(true)
      end
    end
  end
end
