# frozen_string_literal: true

require "spec_helper"

RSpec.describe "have_pipeline_tasks matcher" do
  let(:t1) { create_successful_task(name: "T1") }
  let(:t2) { create_successful_task(name: "T2") }
  let(:t3) { create_successful_task(name: "T3") }

  let(:workflow) do
    a = t1
    b = t2
    c = t3
    create_workflow_class { tasks a, b, c }
  end

  it "passes when pipeline matches (in order)" do
    expect(workflow).to have_pipeline_tasks(t1, t2, t3)
  end

  it "fails when order differs" do
    expect(workflow).not_to have_pipeline_tasks(t1, t3, t2)
  end

  it "passes for any-order match" do
    expect(workflow).to have_pipeline_tasks(t3, t1, t2).in_any_order
  end

  it "rejects non-Workflow input" do
    expect { expect(t1).to have_pipeline_tasks(t1) }.to raise_error(ArgumentError, "must be a CMDx::Workflow")
  end
end
