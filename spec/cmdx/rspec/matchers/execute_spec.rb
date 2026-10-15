# frozen_string_literal: true

require "spec_helper"

RSpec.describe "execute matcher" do
  let(:task_class) { create_task_class(name: "ExecuteMatcherTask") }

  describe "description" do
    it "describes the call, outcome, and count" do
      expect(execute(account_id: 42).description).to eq("execute with {account_id: 42}")
      expect(execute(account_id: 42).once.description).to eq("execute with {account_id: 42} once")
      expect(execute.and_skip(reason: "out of stock").description).to eq('execute and skip with reason "out of stock"')
      expect(execute(account_id: 42).and_fail(reason: "nope").description).to eq('execute with {account_id: 42} and fail with reason "nope"')
      expect(execute!(account_id: 42).and_fail.with_error(NoMethodError, "idk where").description)
        .to eq('execute! with {account_id: 42} and fail with error NoMethodError "idk where"')
      expect(execute.and_succeed.and_output(order_id: 99).description).to eq("execute and succeed with output {order_id: 99}")
      expect(execute.as_deprecated.description).to eq("execute and succeed as deprecated")
      expect(execute.and_fail(reason: "nope").as_deprecated.description).to eq('execute and fail with reason "nope" as deprecated')
    end
  end

  describe "allow" do
    context "when stubbing execute to succeed" do
      it "returns the installed result and seeds context from the call signature" do
        installed = allow(task_class).to execute(account_id: 42).and_succeed(metadata: { id: 1 })

        result = task_class.execute(account_id: 42)

        expect(result).to equal(installed)
        expect(result).to be_successful(metadata: { id: 1 })
        expect(result).to have_matching_context(account_id: 42)
        expect(result.task).to eq(task_class)
        expect(result.strict?).to be(false)
        expect(result.chain.size).to eq(1)
      end

      it "matches any arguments when none are given and leaves context empty" do
        allow(task_class).to execute.and_succeed

        expect(task_class.execute).to be_successful
        expect(task_class.execute(account_id: 42)).to have_empty_context
      end

      it "returns a deferred build_result fixture from and_return" do
        fixture = build_result(account_id: 42).and_succeed(metadata: { id: 1 })
        allow(task_class).to execute.and_return(fixture)

        result = task_class.execute

        expect(result).to be_successful(metadata: { id: 1 })
        expect(result).to have_matching_context(account_id: 42)
      end

      it "rejects a different call signature" do
        allow(task_class).to execute(account_id: 42).and_succeed

        message = nil
        RSpec::Support.with_failure_notifier(->(error, *) { message = error.message }) do
          task_class.execute(account_id: 7)
        end

        expect(message).to include("account_id: 7")
      end
    end

    context "when stubbing execute!" do
      it "returns a strict successful result" do
        result = allow(task_class).to execute!.and_succeed

        expect(task_class.execute!).to equal(result)
        expect(result).to be_successful
        expect(result.strict?).to be(true)
      end
    end

    context "when stubbing a skip" do
      it "returns a skipped result" do
        allow(task_class).to execute(account_id: 42).and_skip(reason: "out of stock")

        expect(task_class.execute(account_id: 42)).to have_skipped(reason: "out of stock")
      end

      it "returns a skipped result from execute!" do
        allow(task_class).to execute!.and_skip(reason: "out of stock")

        result = task_class.execute!

        expect(result).to have_skipped(reason: "out of stock")
        expect(result.strict?).to be(true)
      end
    end

    context "when stubbing a failure" do
      it "returns a failed result" do
        allow(task_class).to execute(account_id: 42).and_fail(reason: "nope")

        expect(task_class.execute(account_id: 42)).to have_failed(reason: "nope")
      end

      it "raises CMDx::Fault from execute!" do
        result = allow(task_class).to execute!(account_id: 42).and_fail(reason: "nope")

        expect(result).to have_failed(reason: "nope")
        expect(result.strict?).to be(true)
        expect { task_class.execute!(account_id: 42) }.to raise_fault(task_class).with_reason("nope")
      end

      it "re-raises cause from execute!" do
        cause = NoMethodError.new("boom")
        allow(task_class).to execute!.and_fail(cause:)

        expect { task_class.execute! }.to raise_error(cause)
      end
    end

    context "when stubbing a rescued error" do
      it "returns a failed result whose cause is the exception" do
        allow(task_class).to execute.and_fail.with_error(CMDx::TestError, "boom")

        result = task_class.execute

        expect(result).to have_failed
        expect(result.cause).to be_a(CMDx::TestError)
        expect(result.reason).to eq("[CMDx::TestError] boom")
      end

      it "keeps an explicit reason and uses an exception instance as cause" do
        cause = CMDx::TestError.new("custom")
        allow(task_class).to execute(account_id: 42).and_fail(reason: "nope").with_error(cause)

        result = task_class.execute(account_id: 42)

        expect(result).to have_failed(reason: "nope")
        expect(result.cause).to equal(cause)
      end
    end

    context "when stubbing throw!" do
      it "echoes an upstream failed result" do
        upstream = create_failing_task(reason: "kaboom").execute(CMDx::Context.new)
        allow(task_class).to execute.and_throw(upstream)

        result = task_class.execute

        expect(result).to have_failed
        expect(result.origin).to equal(upstream)
      end

      it "raises when the upstream result is not failed" do
        ok = create_successful_task.execute(CMDx::Context.new)

        expect { execute.and_throw(ok) }.to raise_error(ArgumentError, "upstream result must be a failed CMDx::Result")
      end
    end

    context "when appending output" do
      it "merges output into context without constraining the call" do
        allow(task_class).to execute(account_id: 42).and_succeed.and_output(order_id: 99)

        result = task_class.execute(account_id: 42)

        expect(result).to be_successful
        expect(result).to have_matching_context(account_id: 42, order_id: 99)
      end
    end

    context "when flagging deprecation" do
      it "returns a successful deprecated result" do
        allow(task_class).to execute.as_deprecated

        result = task_class.execute

        expect(result).to be_successful
        expect(result.deprecated?).to be(true)
      end
    end

    context "when restoring the original implementation" do
      it "runs the real task after and_call_original" do
        original = create_successful_task(name: "OriginalExecuteTask")
        allow(original).to execute(foo: "bar").and_succeed

        stubbed = original.execute(foo: "bar")
        expect(stubbed).to be_successful
        expect(stubbed.context.executed).to be_nil

        allow(original).to execute.and_call_original

        result = original.execute(foo: "bar")
        expect(result).to be_successful
        expect(result.context.executed).to eq([:success])
      end

      it "runs the real task inside and_wrap_original" do
        original = create_successful_task(name: "WrapOriginalExecuteTask")
        wrapped = false

        allow(original).to execute.and_wrap_original do |method, *args, **kwargs, &block|
          wrapped = true
          method.call(*args, **kwargs, &block)
        end

        result = original.execute(foo: "bar")

        expect(wrapped).to be(true)
        expect(result).to be_successful
        expect(result.context.executed).to eq([:success])
      end
    end

    context "when the subject is not a task" do
      it "raises ArgumentError" do
        expect { allow(String).to execute.and_succeed }.to raise_error(ArgumentError, "command must be a Task class")
      end
    end

    context "when using any_instance" do
      it "stubs class execute like allow" do
        allow_any_instance_of(task_class).to execute(account_id: 42).and_succeed # rubocop:disable RSpec/AnyInstance

        expect(task_class.execute(account_id: 42)).to be_successful
      end

      it "expects class execute like expect" do
        expect_any_instance_of(task_class).to execute(account_id: 42) # rubocop:disable RSpec/AnyInstance

        task_class.execute(account_id: 42)
      end
    end

    context "when a second outcome is set" do
      it "raises ArgumentError" do
        expect { execute.and_succeed.and_fail }.to raise_error(ArgumentError, "outcome already set")
      end
    end
  end

  describe "expect" do
    context "when the task is called with the expected signature" do
      it "passes for execute" do
        expect(task_class).to execute(account_id: 42)

        task_class.execute(account_id: 42)
      end

      it "passes for execute with no arguments" do
        expect(task_class).to execute

        task_class.execute
      end

      it "passes for execute! once and returns the stubbed result" do
        expect(task_class).to execute!.and_succeed.once

        expect(task_class.execute!).to be_successful
      end
    end

    context "when the task is not called" do
      it "passes a negative expectation" do
        expect(task_class).not_to execute
      end

      it "allows a different signature" do
        expect(task_class).not_to execute(account_id: 42)

        task_class.execute(account_id: 7)
      end
    end
  end
end
