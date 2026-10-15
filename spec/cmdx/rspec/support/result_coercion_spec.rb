# frozen_string_literal: true

require "spec_helper"

RSpec.describe CMDx::RSpec::Support::ResultCoercion do
  describe ".materialize!" do
    it "returns a CMDx::Result unchanged" do
      result = CMDx::RSpec::Result.for.and_succeed.build

      expect(described_class.materialize!(result)).to equal(result)
    end

    it "materializes a deferred fixture" do
      deferred = CMDx::RSpec::Result.for.and_succeed(metadata: { id: 1 })

      materialized = described_class.materialize!(deferred)

      expect(materialized).to be_a(CMDx::Result)
      expect(materialized).to be_successful(metadata: { id: 1 })
      expect(deferred.materialized?).to be(true)
    end

    it "raises when the value is not a result or deferred fixture" do
      expect { described_class.materialize!(:nope) }.to raise_error(ArgumentError, "must be a CMDx::Result")
    end
  end
end
