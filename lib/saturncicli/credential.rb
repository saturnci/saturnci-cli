require_relative "api_request"
require "json"
require "fileutils"

module SaturnCICLI
  class Credential
    DEFAULT_HOST = "https://app.saturnci.com"
    attr_reader :host, :user_id, :api_token

    def initialize(host: DEFAULT_HOST, user_id:, api_token:, cache_file_path: nil)
      @host = host
      @user_id = user_id
      @api_token = api_token
      @cache_file_path = cache_file_path
    end

    def valid?
      return cache unless cache.nil?
      response_code = api_request.response.code

      if response_code == "200"
        write_cache(true)
      else
        api_request(debug: true).response
        false
      end
    end

    private

    def api_request(debug: false)
      APIRequest.new(
        credential: self,
        method: "GET",
        endpoint: "runs",
        debug:
      )
    end

    def cache
      return nil unless @cache_file_path && File.exist?(@cache_file_path)
      data = JSON.parse(File.read(@cache_file_path))
      data["#{@user_id}:#{@api_token}"]
    end

    def write_cache(value)
      return value unless @cache_file_path
      FileUtils.mkdir_p(File.dirname(@cache_file_path))
      File.write(@cache_file_path, {"#{@user_id}:#{@api_token}" => value}.to_json)
      value
    end
  end
end
