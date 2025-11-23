module SaturnCICLI
  class SSHSession
    def initialize(ip_address:, rsa_key_path:)
      @ip_address = ip_address
      @rsa_key_path = rsa_key_path
    end

    def connect
      system(*command_args)
    end

    def command
      command_args.join(" ")
    end

    private

    def command_args
      [
        "ssh",
        "-o", "StrictHostKeyChecking=accept-new",
        "-i", @rsa_key_path,
        "root@#{@ip_address}"
      ]
    end
  end
end
