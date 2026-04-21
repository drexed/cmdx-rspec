# frozen_string_literal: true

require "spec_helper"

RSpec.describe "raise_cmdx_fault matcher" do
  let(:failing_task) { create_failing_task(name: "FailingCommand", reason: "boom") }

  it "passes for any fault" do
    expect { failing_task.execute!(CMDx::Context.new) }.to raise_cmdx_fault
  end

  it "matches by task class" do
    expect { failing_task.execute!(CMDx::Context.new) }.to raise_cmdx_fault(failing_task)
  end

  it "fails when wrong task class" do
    other = create_failing_task(name: "Other")
    expect { failing_task.execute!(CMDx::Context.new) }.not_to raise_cmdx_fault(other)
  end

  it "matches by reason string" do
    expect { failing_task.execute!(CMDx::Context.new) }.to raise_cmdx_fault.with_reason("boom")
  end

  it "matches by reason regex" do
    expect { failing_task.execute!(CMDx::Context.new) }.to raise_cmdx_fault.with_reason(/oo/)
  end

  it "matches by cause class" do
    cause = CMDx::TestError.new("kaput")
    fault = CMDx::Fault.new(
      CMDx::Result.new(
        CMDx::Chain.new,
        create_failing_task.new(CMDx::Context.new),
        CMDx::Signal.failed("boom", cause: cause),
        root: true,
        id: "x"
      )
    )
    expect { raise fault }.to raise_cmdx_fault.with_cause(CMDx::TestError)
  end

  it "fails when no fault is raised" do
    expect { :ok }.not_to raise_cmdx_fault
  end

  it "rejects non-block input" do
    expect { raise_cmdx_fault.matches?(:not_a_block) }.to raise_error(ArgumentError)
  end
end
