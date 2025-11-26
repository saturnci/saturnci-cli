require_relative "../../lib/saturncicli/credential_loader"
require "tmpdir"
require "fileutils"

describe SaturnCICLI::CredentialLoader do
  let(:temp_dir) { Dir.mktmpdir }
  let(:credentials_file_path) { File.join(temp_dir, "credentials.json") }

  after do
    FileUtils.rm_rf(temp_dir)
  end

  describe ".values" do
    describe "user_id" do
      context "when USER_ID env var is set" do
        it "uses USER_ID env var" do
          env = { "USER_ID" => "my_user_id" }
          result = described_class.values(env: env)
          expect(result[:user_id]).to eq("my_user_id")
        end
      end

      context "when USER_ID env var is not set" do
        it "uses user_id from credentials file" do
          File.write(credentials_file_path, { "user_id" => "file_user_id" }.to_json)
          env = {}
          result = described_class.values(env: env, file_path: credentials_file_path)
          expect(result[:user_id]).to eq("file_user_id")
        end
      end
    end

    describe "api_token" do
      context "when USER_API_TOKEN env var is set" do
        it "uses USER_API_TOKEN env var" do
          env = { "USER_API_TOKEN" => "old_token" }
          result = described_class.values(env: env)
          expect(result[:api_token]).to eq("old_token")
        end
      end

      context "when USER_API_TOKEN env var is not set" do
        it "uses api_token from credentials file" do
          File.write(credentials_file_path, { "api_token" => "file_token" }.to_json)
          env = {}
          result = described_class.values(env: env, file_path: credentials_file_path)
          expect(result[:api_token]).to eq("file_token")
        end
      end
    end

    describe "host" do
      context "when credentials file has a host set" do
        it "uses host from credentials file" do
          File.write(credentials_file_path, { "host" => "https://file.saturnci.com" }.to_json)
          env = {}
          result = described_class.values(env: env, file_path: credentials_file_path)
          expect(result[:host]).to eq("https://file.saturnci.com")
        end
      end

      context "when env var and credentials file do not have host" do
        it "uses the default host" do
          env = {}
          result = described_class.values(env: env)
          expect(result[:host]).to eq(SaturnCICLI::Credential::DEFAULT_HOST)
        end
      end
    end
  end
end
