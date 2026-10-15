# frozen_string_literal: true

require "spec_helper"

RSpec.describe "emit_telemetry matcher" do
  let(:cmd) { create_successful_task(name: "TelemetryTask") }

  it "passes for task_executed events" do
    expect { cmd.execute(CMDx::Context.new) }.to(
      emit_telemetry(:task_executed).on(cmd).once
    )
  end

  it "defaults to all telemetry events when no filter is given" do
    expect { cmd.execute(CMDx::Context.new) }.to(
      emit_telemetry.on(cmd).with_names(:task_started, :task_executed)
    )
  end

  it "supports with_payload on captured events" do
    expect { cmd.execute(CMDx::Context.new) }.to(
      emit_telemetry(:task_executed).on(cmd).with_payload(result: be_a(CMDx::Result))
    )
  end

  it "supports count chains" do
    expect { cmd.execute(CMDx::Context.new) }.to emit_telemetry(:task_executed).on(cmd).once
    expect { cmd.execute(CMDx::Context.new) }.to emit_telemetry.on(cmd).at_least(2)
  end

  it "requires a block" do
    matcher = emit_telemetry(:task_executed).on(cmd)
    expect { matcher.matches?(:not_a_block) }.to raise_error(ArgumentError)
  end

  it "requires .on(Task)" do
    expect do
      emit_telemetry(:task_executed).matches?(proc { cmd.execute(CMDx::Context.new) })
    end.to raise_error(ArgumentError, /command must be set/)
  end

  it "rejects invalid command classes on .on" do
    expect { emit_telemetry.on(String) }.to raise_error(ArgumentError, /Task class/)
  end

  it "fails when no events are emitted" do
    expect { :noop }.not_to emit_telemetry(:task_executed).on(cmd)
  end

  it "captures telemetry from a Task subclass" do
    subclass = Class.new(cmd)

    expect { subclass.execute(CMDx::Context.new) }.to(
      emit_telemetry(:task_executed).on(cmd).once
    )
  end

  it "supports negated count expectations" do
    expect { cmd.execute(CMDx::Context.new) }.not_to emit_telemetry(:task_executed).on(cmd).twice
  end
end
