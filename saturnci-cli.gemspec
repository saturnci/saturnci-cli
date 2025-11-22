Gem::Specification.new do |spec|
  spec.name          = "saturnci-cli"
  spec.version       = "0.1.0"
  spec.authors       = ["Jason Swett"]
  spec.email         = ["jasonswett@gmail.com"]

  spec.summary       = "Command-line interface for SaturnCI"
  spec.description   = "CLI tool for interacting with SaturnCI test runners, builds, and test suite runs"
  spec.homepage      = "https://github.com/saturnci/saturnci-cli"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*", "bin/*", "README.md"]
  spec.bindir        = "bin"
  spec.executables   = ["saturnci"]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 3.0.0"
end
