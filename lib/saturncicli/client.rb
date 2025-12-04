require "json"
require_relative "api_request"
require_relative "display/table"
require_relative "ssh_session"
require_relative "worker"

module SaturnCICLI
  class Client
    DEFAULT_LIMIT = 50

    ALLOWED_COMMANDS = [
      :workers,
      :delete_worker,
      :delete_all_workers,
      :ssh_by_worker_id,
      :test_suite_runs,
      :test_suite_run,
      :runs,
      :run
    ].freeze

    def initialize(credential)
      @credential = credential
    end

    def execute(command)
      method_name = command[0]
      args = command[1..-1]

      unless ALLOWED_COMMANDS.include?(method_name)
        raise ArgumentError, "Unknown command: #{method_name}"
      end

      public_send(method_name, *args)
    end

    def workers
      response = get("workers")

      if response.code != "200"
        puts "Request failed"
        puts response.inspect
        return
      end

      workers = JSON.parse(response.body)

      puts Display::Table.new(
        resource_name: :worker,
        items: workers[0..DEFAULT_LIMIT-1],
      )
    end

    def delete_worker(worker_ids)
      worker_ids.each do |worker_id|
        response = delete("workers/#{worker_id}")
        puts response.inspect
      end
    end

    def delete_all_workers
      response = delete("worker_collection")
      puts response.inspect
    end

    def test_suite_runs(options = {})
      response = get("test_suite_runs")

      if response.code == "500"
        puts "500 Internal Server Error"
        return
      end

      test_suite_runs = JSON.parse(response.body)

      puts Display::Table.new(
        resource_name: :test_suite_run,
        items: test_suite_runs[0..DEFAULT_LIMIT-1],
        options: options
      )
    end

    def runs(options = {})
      response = get("runs")
      runs = JSON.parse(response.body)

      puts Display::Table.new(
        resource_name: :run,
        items: runs[0..DEFAULT_LIMIT-1],
        options: options
      )
    end

    def run(run_id)
      response = get("runs/#{run_id}")
      run_attrs = JSON.parse(response.body)

      run_attrs.each do |key, value|
        puts "#{key}: #{value}"
      end
    end

    def test_suite_run(test_suite_run_id)
      response = get("test_suite_runs/#{test_suite_run_id}")
      data = JSON.parse(response.body)

      puts "Test Suite Run: #{data["id"]}"
      puts "Status: #{data["status"]}"
      puts "Branch: #{data["branch_name"]}"
      puts "Commit: #{data["commit_hash"]}"
      puts

      if data["failed_tests"].empty?
        puts "No failed tests."
      else
        puts "Failed Tests (#{data["failed_tests"].count}):"
        puts
        data["failed_tests"].each do |test|
          puts "#{test["path"]}:#{test["line_number"]}"
          puts "  #{test["description"]}"
          puts "  #{test["exception_message"]}"
          puts
        end
      end
    end

    def ssh_by_worker_id(worker_id)
      worker = Worker.new(
        id: worker_id,
        readiness_check_request: -> { get("workers/#{worker_id}") }
      )

      ssh(worker)
    end

    def ssh(worker)
      until worker.refresh.ip_address
        puts "Waiting for IP address..."
        sleep(Worker::WAIT_INTERVAL_IN_SECONDS)
      end

      ssh_session = SSHSession.new(
        ip_address: worker.ip_address,
        rsa_key_path: worker.rsa_key_path
      )

      response = patch("workers/#{worker.id}", { "terminate_on_completion" => false })
      raise "Problem: #{response.inspect}" unless response.code == "200"
      puts ssh_session.command
      ssh_session.connect
    end

    private

    def get(endpoint)
      APIRequest.new(
        credential: @credential,
        method: "GET",
        endpoint:,
        debug: ENV["DEBUG"]
      ).response
    end

    def patch(endpoint, body)
      APIRequest.new(
        credential: @credential,
        method: "PATCH",
        endpoint:,
        body:,
        debug: ENV["DEBUG"]
      ).response
    end

    def delete(endpoint)
      APIRequest.new(
        credential: @credential,
        method: "DELETE",
        endpoint:,
        debug: ENV["DEBUG"]
      ).response
    end
  end
end
