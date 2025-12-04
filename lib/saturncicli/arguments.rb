module SaturnCICLI
  class Arguments
    def initialize(argv)
      @argv = argv
    end

    def command
      case @argv[0]
      when "workers"
        case @argv[1]
        when nil
          [:workers]
        when "delete"
          if @argv[2] == "--all"
            [:delete_all_workers]
          else
            worker_ids = @argv[2..-1]
            [:delete_worker, worker_ids]
          end
        when "ssh"
          worker_id = @argv[2]
          [:ssh_by_worker_id, worker_id]
        end
      when "runs"
        [:runs]
      when "run"
        run_id = @argv[1]
        [:run, run_id]
      when "test-suite-runs"
        [:test_suite_runs]
      when "test-suite-run"
        test_suite_run_id = @argv[1]
        [:test_suite_run, test_suite_run_id]
      when nil
        [:workers]
      else
        fail "Unknown argument \"#{@argv.join(" ")}\""
      end
    end
  end
end
