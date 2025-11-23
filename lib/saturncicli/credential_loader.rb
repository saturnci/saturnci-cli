require_relative "credential"

module SaturnCICLI
  class CredentialLoader
    def self.values(env:)
      {
        host: env["SATURNCI_API_HOST"] || Credential::DEFAULT_HOST,
        user_id: env["SATURNCI_USER_ID"] || env["USER_ID"],
        api_token: env["SATURNCI_API_TOKEN"] || env["USER_API_TOKEN"]
      }
    end
  end
end
