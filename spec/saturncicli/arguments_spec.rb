require_relative "../../lib/saturncicli/arguments"

describe SaturnCICLI::Arguments do
  context "run abc123" do
    it "calls run" do
      argv = %w(run abc123)
      arguments = SaturnCICLI::Arguments.new(argv)
      expect(arguments.command).to eq([:run, "abc123"])
    end
  end

  context "workers delete abc123 def456" do
    it "calls delete_worker" do
      argv = %w(workers delete abc123 def456)
      arguments = SaturnCICLI::Arguments.new(argv)
      expect(arguments.command).to eq([:delete_worker, ["abc123", "def456"]])
    end
  end

  context "workers delete --all" do
    it "calls delete_all_workers" do
      argv = %w(workers delete --all)
      arguments = SaturnCICLI::Arguments.new(argv)
      expect(arguments.command).to eq([:delete_all_workers])
    end
  end

  context "workers" do
    it "calls workers" do
      argv = %w(workers)
      arguments = SaturnCICLI::Arguments.new(argv)
      expect(arguments.command).to eq([:workers])
    end
  end

  context "test-suite-run abc123" do
    it "calls test_suite_run" do
      argv = %w(test-suite-run abc123)
      arguments = SaturnCICLI::Arguments.new(argv)
      expect(arguments.command).to eq([:test_suite_run, "abc123"])
    end
  end
end
