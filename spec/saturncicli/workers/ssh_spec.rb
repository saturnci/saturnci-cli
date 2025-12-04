require_relative "../helpers/authentication_helper"
require_relative "../helpers/api_helper"
require_relative "../../../lib/saturncicli/credential"
require_relative "../../../lib/saturncicli/client"

describe "ssh" do
  before do
    AuthenticationHelper.stub_authentication_request
    allow_any_instance_of(SaturnCICLI::SSHSession).to receive(:connect)

    stub_request(:patch, "https://app.saturnci.com/api/v1/workers/abc123").
      to_return(status: 200, body: "", headers: {})
  end

  let!(:credential) do
    SaturnCICLI::Credential.new(
      user_id: "valid_user_id",
      api_token: "valid_api_token"
    )
  end


  let!(:client) do
    SaturnCICLI::Client.new(credential)
  end

  let!(:worker) do
    instance_double(SaturnCICLI::Worker)
  end

  before do
    allow(worker).to receive(:refresh).and_return(worker)
    allow(worker).to receive(:id).and_return("abc123")
  end

  context "remote machine has an IP address" do
    let!(:body) do
      { "ip_address" => "111.11.11.1" }
    end

    before do
      APIHelper.stub_body("api/v1/workers/abc123", body)
      allow(worker).to receive(:ip_address).and_return("111.11.11.1")
      allow(worker).to receive(:rsa_key_path).and_return("/tmp/saturnci/worker-abc123")
    end

    it "outputs the worker id" do
      expect do
        command = "--worker abc123 ssh"
        client.ssh(worker)
      end.to output("ssh -o StrictHostKeyChecking=accept-new -i /tmp/saturnci/worker-abc123 root@111.11.11.1\n").to_stdout
    end
  end

  context "remote machine does not yet have an IP address" do
    before do
      APIHelper.stub_body("api/v1/workers/abc123", {})
      allow(worker).to receive(:ip_address).and_return(nil, "111.11.11.1")
      allow(worker).to receive(:rsa_key_path).and_return("/tmp/saturnci/worker-abc123")
    end

    it "outputs a message" do
      expect do
        command = "--worker abc123 ssh"
        client.ssh(worker)
      end.to output("Waiting for IP address...\nssh -o StrictHostKeyChecking=accept-new -i /tmp/saturnci/worker-abc123 root@111.11.11.1\n").to_stdout
    end
  end

  describe "terminate on completion" do
    before do
      allow(worker).to receive(:ip_address).and_return("111.11.11.1")
      allow(worker).to receive(:rsa_key_path).and_return("/tmp/saturnci/worker-abc123")
    end

    it "sends a request to set terminate_on_completion to false" do
      client.ssh(worker)

      expect(a_request(:patch, "https://app.saturnci.com/api/v1/workers/abc123"))
        .to have_been_made.once
    end
  end
end
