require_relative "credential"
require "json"

module SaturnCICLI
  class CredentialLoader
    DEFAULT_FILE_PATH = File.join(Dir.home, ".saturnci", "credentials.json")

    def self.values(env:, file_path: DEFAULT_FILE_PATH)
      file_credentials = load_file(file_path)

      {
        host: file_credentials["host"] || Credential::DEFAULT_HOST,
        user_id: env["USER_ID"] || file_credentials["user_id"],
        api_token: env["USER_API_TOKEN"] || file_credentials["api_token"]
      }
    end

    private

    def self.load_file(file_path)
      return {} unless file_path && File.exist?(file_path)
      JSON.parse(File.read(file_path))
    end
  end
end
