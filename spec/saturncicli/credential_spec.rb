require_relative "../../lib/saturncicli/credential"
require "webmock/rspec"
require "tmpdir"
require "fileutils"

describe SaturnCICLI::Credential do
  let(:cache_dir) { Dir.mktmpdir }
  let(:cache_file_path) { File.join(cache_dir, "cache.json") }
  let(:user_id) { "test_user_id" }
  let(:api_token) { "test_api_token" }

  after do
    FileUtils.rm_rf(cache_dir)
  end

  describe "#valid?" do
    context "when the cache is cold" do
      before do
        stub_request(:get, "#{SaturnCICLI::Credential::DEFAULT_HOST}/api/v1/runs")
          .to_return(status: 200, body: "[]")
      end

      it "makes an API request" do
        credential = described_class.new(
          user_id: user_id,
          api_token: api_token,
          cache_file_path: cache_file_path
        )
        credential.valid?
        expect(WebMock).to have_requested(:get, "#{SaturnCICLI::Credential::DEFAULT_HOST}/api/v1/runs")
      end
    end

    context "when credentials are invalid" do
      before do
        stub_request(:get, "#{SaturnCICLI::Credential::DEFAULT_HOST}/api/v1/runs")
          .to_return(status: 401, body: "")
      end

      it "outputs something" do
        credential = described_class.new(
          user_id: user_id,
          api_token: api_token,
          cache_file_path: cache_file_path
        )
        expect { credential.valid? }.to output.to_stdout
      end

      it "does not cache the failure" do
        # First invocation with invalid credentials
        first_invocation = described_class.new(
          user_id: user_id,
          api_token: api_token,
          cache_file_path: cache_file_path
        )
        first_invocation.valid?

        # Second invocation should also make a request (failure not cached)
        second_invocation = described_class.new(
          user_id: user_id,
          api_token: api_token,
          cache_file_path: cache_file_path
        )
        second_invocation.valid?

        expect(WebMock).to have_requested(:get, "#{SaturnCICLI::Credential::DEFAULT_HOST}/api/v1/runs").times(4)
      end
    end

    context "when the cache is warm" do
      before do
        stub_request(:get, "#{SaturnCICLI::Credential::DEFAULT_HOST}/api/v1/runs")
          .to_return(status: 200, body: "[]")

        # First invocation - warms up the cache
        first_invocation = described_class.new(
          user_id: user_id,
          api_token: api_token,
          cache_file_path: cache_file_path
        )
        first_invocation.valid?
      end

      it "does not make an API request" do
        # Second invocation - reads from cache
        second_invocation = described_class.new(
          user_id: user_id,
          api_token: api_token,
          cache_file_path: cache_file_path
        )
        second_invocation.valid?
        expect(WebMock).to have_requested(:get, "#{SaturnCICLI::Credential::DEFAULT_HOST}/api/v1/runs").once
      end
    end
  end
end
