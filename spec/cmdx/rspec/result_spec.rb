# frozen_string_literal: true

require "spec_helper"

RSpec.describe CMDx::RSpec::Result do
  let(:snapshot) { { id: 1, state: "ready" } }

  describe ".for / #build" do
    it "builds a successful result with context from keywords" do
      built = described_class.for(snapshot:).and_succeed.build

      expect(built).to be_successful
      expect(built).to have_matching_context(snapshot:)
    end

    it "accepts a pre-built signal" do
      signal = CMDx::Signal.success("done", metadata: { rows: 2 })
      built = described_class.for(snapshot:).from_signal(signal).build

      expect(built).to be_successful(reason: "done", metadata: { rows: 2 })
    end

    it "returns a deferred fixture from from_signal without build" do
      signal = CMDx::Signal.success("done")
      deferred = described_class.for.from_signal(signal)

      expect(deferred).to be_a(CMDx::RSpec::Support::ResultDeferred)
      expect(deferred).to be_successful(reason: "done")
    end

    it "succeeds from context output alone" do
      built = described_class.for.and_output(snapshot:).build

      expect(built).to be_successful
      expect(built).to have_matching_context(snapshot:)
    end

    it "succeeds from as_deprecated alone" do
      built = described_class.for.as_deprecated.build

      expect(built).to be_successful
      expect(built.deprecated?).to be(true)
    end

    it "uses a stub task class when none is given" do
      task_class = Class.new(CMDx::Task)
      built = described_class.for.and_succeed.build
      built_on_class = described_class.for.on(task_class).and_succeed.build

      expect(built.task).to be_a(Class)
      expect(built.task).to be < CMDx::Task
      expect(built.task).not_to eq(task_class)
      expect(built_on_class.task).to eq(task_class)
    end

    it "records as_root and with_tid" do
      tid = SecureRandom.uuid_v7
      built = described_class.for.and_succeed.as_root(value: false).with_tid(tid).build

      expect(built.root?).to be(false)
      expect(built.tid).to eq(tid)
    end

    it "joins an existing chain" do
      chain = CMDx::Chain.new
      first = described_class.for.on_chain(chain).and_succeed.build
      second = described_class.for.on_chain(chain).and_succeed.build

      expect(chain.size).to eq(2)
      expect(second.chain).to equal(chain)
      expect(first.chain).to equal(chain)
    end

    it "accepts an explicit CMDx::Context" do
      ctx = CMDx::Context.new(snapshot:)

      built = described_class.for.with_context(ctx).and_succeed.build

      expect(built).to have_matching_context(snapshot:)
    end

    it "forwards lifecycle options" do
      built = described_class.for.and_succeed.strict.as_deprecated.with_retries(2).rolled_back.build

      expect(built.strict?).to be(true)
      expect(built.deprecated?).to be(true)
      expect(built.retries).to eq(2)
      expect(built.rolled_back?).to be(true)
    end

    it "raises when no outcome or signal was configured" do
      expect { described_class.for.build }.to raise_error(ArgumentError, /outcome required/)
    end

    it "records with_duration on the built result" do
      built = described_class.for.and_succeed.with_duration(42.0).build

      expect(built.duration).to eq(42.0)
    end
  end

  describe "outcome chains" do
    let(:task_class) { Class.new(CMDx::Task) }

    it "builds a successful result with metadata" do
      built = described_class.for(snapshot:).and_succeed(metadata: { id: 1 }).build

      expect(built).to be_successful(metadata: { id: 1 })
    end

    it "uses the supplied task class" do
      built = described_class.for.on(task_class).and_succeed.build

      expect(built.task).to eq(task_class)
    end

    it "builds a skipped result" do
      built = described_class.for(snapshot:).and_skip(reason: "not applicable").build

      expect(built).to have_skipped(reason: "not applicable")
      expect(built).to have_matching_context(snapshot:)
    end

    it "builds a failed result" do
      cause = StandardError.new("kaput")
      built = described_class.for(snapshot:).and_fail(reason: "failed", cause:).build

      expect(built).to have_failed(reason: "failed", cause:)
      expect(built).to have_matching_context(snapshot:)
    end

    it "builds an echoed result" do
      upstream = described_class.for.and_fail(reason: "kaboom").build
      built = described_class.for.and_throw(upstream).build

      expect(built).to have_failed(reason: upstream.reason)
    end

    it "raises when echoing a non-failed upstream result" do
      ok = described_class.for.and_succeed.build

      expect { described_class.for.and_throw(ok).build }.to raise_error(
        ArgumentError,
        "upstream result must be a failed CMDx::Result"
      )
    end

    it "builds a failed result from with_error" do
      built = described_class.for(snapshot:).with_error(CMDx::TestError, "boom").build

      expect(built).to have_failed
      expect(built.cause).to be_a(CMDx::TestError)
      expect(built.reason).to eq("[CMDx::TestError] boom")
      expect(built).to have_matching_context(snapshot:)
    end
  end

  describe "Matchers.build_result factory" do
    it "returns a configured builder" do
      built = described_class.for(snapshot:).and_succeed(metadata: { id: 1 }).build

      expect(built).to be_successful(metadata: { id: 1 })
      expect(built).to have_matching_context(snapshot:)
    end

    it "is available as Matchers#build_result" do
      group = Class.new do
        include CMDx::RSpec::Matchers
      end

      built = group.new.build_result(snapshot:).and_succeed

      expect(built).to be_successful
      expect(built).to have_matching_context(snapshot:)
    end
  end

  describe "Support::ResultDeferred" do
    let(:task_class) { Class.new(CMDx::Task) }

    it "materializes without an explicit build after and_succeed" do
      built = described_class.for(snapshot:).and_succeed

      expect(built).to be_a(CMDx::RSpec::Support::ResultDeferred)
      expect(built).to be_successful
      expect(built).to have_matching_context(snapshot:)
    end

    it "chains lifecycle options before materializing" do
      built = described_class.for.and_succeed.with_duration(1.0)

      expect(built).to be_successful
      expect(built.duration).to eq(1.0)
    end

    it "accepts task and context keywords via build_result" do
      group = Class.new do
        include CMDx::RSpec::Matchers
      end

      built = group.new.build_result(task_class, snapshot:).and_succeed

      expect(built.task).to eq(task_class)
      expect(built).to have_matching_context(snapshot:)
    end

    it "materializes context keywords after and_succeed without build" do
      built = described_class.for(snapshot:).and_succeed

      expect(built).to be_successful
      expect(built).to have_matching_context(snapshot:)
    end

    it "accepts a deferred upstream for and_throw" do
      upstream = described_class.for.and_fail(reason: "kaboom")
      built = described_class.for.and_throw(upstream)

      expect(built).to have_failed(reason: "kaboom")
    end

    it "reports pending state in inspect before materialization" do
      deferred = described_class.for.and_succeed

      expect(deferred.inspect).to include("pending")
      expect(deferred.materialized?).to be(false)

      deferred.materialize

      expect(deferred.materialized?).to be(true)
      expect(deferred.inspect).not_to include("pending")
    end

    it "compares equal to a materialized result with the same attributes" do
      deferred = described_class.for.and_succeed(metadata: { id: 1 })
      built = deferred.build

      expect(deferred).to eq(built)
      expect(deferred.eql?(built)).to be(true)
    end

    it "forwards unknown methods to the materialized result" do
      deferred = described_class.for.and_succeed(metadata: { id: 1 })

      expect(deferred).to respond_to(:metadata)
      expect(deferred.metadata).to eq({ id: 1 })
    end
  end
end
