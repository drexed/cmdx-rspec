# frozen_string_literal: true

require "spec_helper"

RSpec.describe "additional CMDx::RSpec::Helpers" do
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

  describe "#stub_task_deprecated" do
    it "marks the result as deprecated" do
      stub_task_deprecated(task_class)
      result = task_class.execute
      expect(result).to be_successful
      expect(result.deprecated?).to be(true)
    end
  end

  describe "#capture_cmdx_logs" do
    it "captures lines emitted within the block" do
      lines = capture_cmdx_logs do
        CMDx.configuration.logger.info("hello world")
      end
      expect(lines.join).to include("hello world")
    end

    it "restores the original logger" do
      original = CMDx.configuration.logger
      capture_cmdx_logs { :noop }
      expect(CMDx.configuration.logger).to equal(original)
    end

    it "raises without a block" do
      expect { capture_cmdx_logs }.to raise_error(ArgumentError)
    end
  end

  describe "#subscribe_telemetry" do
    it "captures task_executed events" do
      cmd = create_successful_task(name: "TelemetryTask")
      events = subscribe_telemetry(cmd, :task_executed) { cmd.execute(CMDx::Context.new) }
      expect(events.map(&:name)).to eq([:task_executed])
    end

    it "defaults to all telemetry events" do
      cmd = create_successful_task(name: "TelemetryTaskAll")
      events = subscribe_telemetry(cmd) { cmd.execute(CMDx::Context.new) }
      expect(events.map(&:name)).to include(:task_started, :task_executed)
    end

    it "raises without a block" do
      expect { subscribe_telemetry(create_successful_task) }.to raise_error(ArgumentError)
    end
  end

  describe "#with_cmdx_chain" do
    it "captures the chain produced by command's execution" do
      cmd = create_successful_task(name: "ChainTask")
      chain = with_cmdx_chain(cmd) { cmd.execute(CMDx::Context.new) }
      expect(chain).to be_a(CMDx::Chain)
      expect(chain.size).to eq(1)
    end

    it "returns nil when no root execution happened" do
      cmd = create_successful_task(name: "ChainTaskNone")
      expect(with_cmdx_chain(cmd) { :noop }).to be_nil
    end
  end
end
