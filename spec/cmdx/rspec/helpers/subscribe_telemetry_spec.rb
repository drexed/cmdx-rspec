# frozen_string_literal: true

require "spec_helper"

RSpec.describe "CMDx::RSpec::Helpers subscribe_telemetry" do
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
end
