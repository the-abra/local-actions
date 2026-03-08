# Local Actions Runner

A shell-based tool to run GitHub Actions steps locally using Docker.

## Features

- Parses GitHub Actions workflow files (YAML).
- Runs shell commands (`run` steps) inside a Docker container.
- **Privacy Focused**: Automatically detects and skips steps that reference GitHub secrets (`${{ secrets... }}`) to prevent credential leaks.

## Prerequisites

- Docker
- yq (YAML processor)

## Usage

```bash
./run-local.sh <workflow-file> <docker-image> [job-name]
```

### Example

```bash
./run-local.sh examples/ci.yml ubuntu:latest
```

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details on how to get started.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
