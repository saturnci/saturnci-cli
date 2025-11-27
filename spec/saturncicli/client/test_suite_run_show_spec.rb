require_relative "../../../lib/saturncicli/credential"
require_relative "../../../lib/saturncicli/client"

describe "test suite run show" do
  before do
    body = {
      "id" => "abc123",
      "status" => "Failed",
      "branch_name" => "main",
      "commit_hash" => "def456",
      "commit_message" => "Fix bug",
      "failed_tests" => [
        {
          "path" => "spec/models/user_spec.rb",
          "line_number" => 42,
          "description" => "validates email",
          "exception_message" => "expected nil to be present"
        }
      ]
    }.to_json

    stub_request(:get, "#{SaturnCICLI::Credential::DEFAULT_HOST}/api/v1/test_suite_runs/abc123")
      .to_return(body: body, status: 200)
  end

  let!(:client) do
    credential = SaturnCICLI::Credential.new(
      user_id: "valid_user_id",
      api_token: "valid_api_token"
    )

    SaturnCICLI::Client.new(credential)
  end

  it "displays failed test details" do
    expect { client.test_suite_run("abc123") }
      .to output(/spec\/models\/user_spec.rb:42/).to_stdout
  end
end
