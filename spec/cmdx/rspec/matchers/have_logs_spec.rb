# frozen_string_literal: true

require "spec_helper"

RSpec.describe "have_logs matcher" do
  it "passes when logs include expected text" do
    expect do
      CMDx.configuration.logger.info("hello world")
    end.to have_logs.including("hello world")
  end

  it "accepts a composable matcher on joined text" do
    expect do
      CMDx.configuration.logger.info("status=success")
    end.to have_logs(include("status=success"))
  end

  it "matches line arrays with on_lines" do
    expect do
      CMDx.configuration.logger.info("line-a")
      CMDx.configuration.logger.info("line-b")
    end.to have_logs(include(a_string_including("line-a"), a_string_including("line-b"))).on_lines
  end

  it "supports regexp matching" do
    expect do
      CMDx.configuration.logger.info("status=success")
    end.to have_logs.matching(/status=\w+/)
  end

  it "supports count chains on line count" do
    expect do
      CMDx.configuration.logger.info("one")
    end.to have_logs.once

    expect do
      CMDx.configuration.logger.info("one")
      CMDx.configuration.logger.info("two")
    end.to have_logs.twice
  end

  it "supports with_line_count" do
    expect do
      CMDx.configuration.logger.info("only")
    end.to have_logs.with_line_count(1)
  end

  it "restores the original logger" do
    original = CMDx.configuration.logger
    expect { :noop }.not_to have_logs
    expect(CMDx.configuration.logger).to equal(original)
  end

  it "fails when nothing was logged" do
    expect { :noop }.not_to have_logs
  end

  it "rejects non-block input" do
    expect { have_logs.matches?(:not_a_block) }.to raise_error(ArgumentError)
  end
end
