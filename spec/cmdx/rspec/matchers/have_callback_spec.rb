# frozen_string_literal: true

require "spec_helper"

RSpec.describe "have_callback matcher" do
  let(:my_callable) { ->(_t) {} }

  let(:task_class) do
    cb = my_callable
    create_task_class do
      before_execution :authenticate!
      on_failed cb
      define_method(:authenticate!) { :ok }
    end
  end

  it "passes when any callback registered for event" do
    expect(task_class).to have_callback(:before_execution)
  end

  it "fails when event has no callbacks" do
    expect(task_class).not_to have_callback(:on_success)
  end

  it "matches a Symbol callback" do
    expect(task_class).to have_callback(:before_execution, :authenticate!)
  end

  it "matches a callable by reference" do
    expect(task_class).to have_callback(:on_failed, my_callable)
  end

  it "fails when callable mismatches" do
    expect(task_class).not_to have_callback(:before_execution, :other_method)
  end
end
