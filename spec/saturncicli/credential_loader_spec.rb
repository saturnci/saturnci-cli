require_relative "../../lib/saturncicli/credential_loader"

describe SaturnCICLI::CredentialLoader do
  describe ".values" do
    describe "user_id" do
      context "when SATURNCI_USER_ID env var is set" do
        it "uses SATURNCI_USER_ID" do
          env = { "SATURNCI_USER_ID" => "new_user_id", "USER_ID" => "old_user_id" }
          result = described_class.values(env: env)
          expect(result[:user_id]).to eq("new_user_id")
        end
      end

      context "when SATURNCI_USER_ID env var is not set" do
        it "uses legacy USER_ID env var" do
          env = { "USER_ID" => "old_user_id" }
          result = described_class.values(env: env)
          expect(result[:user_id]).to eq("old_user_id")
        end
      end
    end

    describe "api_token" do
      context "when SATURNCI_API_TOKEN env var is set" do
        it "uses SATURNCI_API_TOKEN" do
          env = { "SATURNCI_API_TOKEN" => "new_token", "USER_API_TOKEN" => "old_token" }
          result = described_class.values(env: env)
          expect(result[:api_token]).to eq("new_token")
        end
      end

      context "when SATURNCI_API_TOKEN env var is not set" do
        it "uses legacy USER_API_TOKEN env var" do
          env = { "USER_API_TOKEN" => "old_token" }
          result = described_class.values(env: env)
          expect(result[:api_token]).to eq("old_token")
        end
      end
    end

    describe "host" do
      context "when SATURNCI_API_HOST env var is set" do
        it "uses SATURNCI_API_HOST" do
          env = { "SATURNCI_API_HOST" => "https://custom.saturnci.com" }
          result = described_class.values(env: env)
          expect(result[:host]).to eq("https://custom.saturnci.com")
        end
      end

      context "when SATURNCI_API_HOST env var is not set" do
        it "uses the default host" do
          env = {}
          result = described_class.values(env: env)
          expect(result[:host]).to eq(SaturnCICLI::Credential::DEFAULT_HOST)
        end
      end
    end
  end
end
