# SaturnCI CLI

Command-line interface for interacting with SaturnCI.

## Installation

```bash
gem install saturnci-cli
```

## Usage

Set your credentials as environment variables:

```bash
export USER_ID=your-user-id
export USER_API_TOKEN=your-api-token
```

Optional: Set a custom API host (defaults to https://app.saturnci.com):

```bash
export SATURNCI_API_HOST=http://localhost:3000
```

### Available Commands

List workers:
```bash
saturnci workers
```

Delete workers:
```bash
saturnci workers delete <worker-id> [<worker-id>...]
saturnci workers delete --all
```

SSH into a worker:
```bash
saturnci workers ssh <worker-id>
```

List test suite runs:
```bash
saturnci test-suite-runs
```

List runs:
```bash
saturnci runs
```

Show run details:
```bash
saturnci run <run-id>
```

## Development

Clone the repository:

```bash
git clone https://github.com/saturnci/saturnci-cli.git
cd saturnci-cli
```

Install dependencies:

```bash
bundle install
```

Run tests:

```bash
bundle exec rspec
```

**Note:** If you encounter a bigdecimal loading error with Ruby 3.4, this is a known webmock compatibility issue. Tests can be run on Ruby 3.3 or earlier, or run specific non-webmock tests like `bundle exec rspec spec/saturncicli/arguments_spec.rb --require ./lib/saturncicli/arguments.rb`

## License

MIT
