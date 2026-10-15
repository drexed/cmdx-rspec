# frozen_string_literal: true

require "spec_helper"

RSpec.describe "have_executed matcher" do
  let(:task_class) { create_task_class(name: "HaveExecutedMatcherTask") }

  describe "description" do
    it "describes the recorded call" do
      expect(have_executed(account_id: 42).description).to eq("have executed with {account_id: 42}")
      expect(have_executed(account_id: 42).once.description).to eq("have executed with {account_id: 42} once")
      expect(have_executed!.description).to eq("have executed!")
    end
  end

  describe "expect" do
    context "when execute was called" do
      it "passes for the matching signature" do
        allow(task_class).to execute.and_succeed
        task_class.execute(account_id: 42)

        expect(task_class).to have_executed(account_id: 42).once
      end

      it "passes with no arguments" do
        allow(task_class).to execute.and_succeed
        task_class.execute

        expect(task_class).to have_executed
      end

      it "passes for execute!" do
        allow(task_class).to execute!.and_succeed
        task_class.execute!

        expect(task_class).to have_executed!
      end

      it "passes after allow(...).to execute.and_wrap_original" do
        task = create_successful_task(name: "HaveExecutedWrapTask")

        allow(task).to(execute.and_wrap_original { |method, *args, **kwargs, &block| method.call(*args, **kwargs, &block) })
        task.execute(account_id: 42)

        expect(task).to have_executed(account_id: 42).once
      end
    end

    context "when execute was not called" do
      it "passes a negative expectation" do
        allow(task_class).to execute

        expect(task_class).not_to have_executed
      end

      it "reports a failure message naming the call" do
        allow(task_class).to execute
        matcher = have_executed(account_id: 42)

        expect(matcher.matches?(task_class)).not_to be(true)
        expect(matcher.failure_message).to include("execute").and include("account_id: 42")
      end
    end

    context "when execute was not stubbed" do
      it "raises because there is no spy" do
        message = nil
        RSpec::Support.with_failure_notifier(->(error, *) { message = error.message }) do
          have_executed.matches?(task_class)
        end

        expect(message).to include("not been stubbed")
      end
    end

    context "when a count chain is negated" do
      it "raises" do
        allow(task_class).to execute

        message = nil
        RSpec::Support.with_failure_notifier(->(error, *) { message = error.message }) do
          have_executed.once.does_not_match?(task_class)
        end

        expect(message).to include("once")
      end
    end

    context "when the subject is not a task" do
      it "raises ArgumentError" do
        expect { expect(String).to have_executed }.to raise_error(ArgumentError, "command must be a Task class")
      end
    end
  end

  describe "allow" do
    it "is rejected" do
      expect { allow(task_class).to have_executed }
        .to raise_error(ArgumentError, /have_executed/)
    end
  end

  describe "expect_any_instance_of" do
    context "when instance execute was called" do
      it "passes after allow_any_instance_of and class execute" do
        allow_any_instance_of(task_class).to execute.and_succeed # rubocop:disable RSpec/AnyInstance

        task_class.execute(account_id: 42)

        expect_any_instance_of(task_class).to have_executed.once # rubocop:disable RSpec/AnyInstance
      end

      it "passes for execute! with strict: true" do
        allow_any_instance_of(task_class).to execute!.and_succeed # rubocop:disable RSpec/AnyInstance

        task_class.execute!

        expect_any_instance_of(task_class).to have_executed! # rubocop:disable RSpec/AnyInstance
      end
    end

    context "when instance execute was not called" do
      it "passes a negative expectation" do
        allow_any_instance_of(task_class).to execute # rubocop:disable RSpec/AnyInstance

        matcher = have_executed
        matcher.instance_variable_set(:@any_instance, true)

        expect(matcher.does_not_match?(task_class)).to be(true)
      end
    end

    context "when execute was not stubbed on any instance" do
      it "raises because there is no spy" do
        matcher = have_executed
        matcher.instance_variable_set(:@any_instance, true)

        message = nil
        RSpec::Support.with_failure_notifier(->(error, *) { message = error.message }) do
          matcher.matches?(task_class)
        end

        expect(message).to include("not been stubbed")
      end
    end
  end
end
