# frozen_string_literal: true

require "spec_helper"

RSpec.describe "have_middleware matcher" do
  let(:middleware_class) do
    Class.new do
      def call(_task)
        yield
      end
    end
  end

  let(:task_class) do
    mw = middleware_class.new
    create_task_class { register :middleware, mw }
  end

  it "passes when middleware is registered (instance)" do
    instance = task_class.middlewares.registry.first
    expect(task_class).to have_middleware(instance)
  end

  it "passes when middleware matches by class" do
    expect(task_class).to have_middleware(middleware_class)
  end

  it "fails when middleware not registered" do
    other = Class.new do
      def call(_task)
        yield
      end
    end
    expect(task_class).not_to have_middleware(other)
  end
end
