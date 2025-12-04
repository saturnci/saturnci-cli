require "spec_helper"
require_relative "../../lib/saturncicli/worker"

describe SaturnCICLI::Worker do
  describe "#rsa_key_path" do
    let!(:worker) do
      response = double(
        "Response",
        body: { rsa_key: Base64.encode64("FAKE_RSA_KEY_CONTENT") }.to_json
      )

      allow(response).to receive(:code).and_return("200")

      SaturnCICLI::Worker.new(
        id: "abc123",
        readiness_check_request: -> { response }
      )
    end

    it "returns a path" do
      worker.refresh
      expect(worker.rsa_key_path).not_to be_nil
    end

    it "puts the key in a file" do
      worker.refresh
      expect(File.read(worker.rsa_key_path)).to eq("FAKE_RSA_KEY_CONTENT")
    end
  end
end
