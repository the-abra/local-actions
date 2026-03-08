# laction (Local Actions Runner)

A privacy-focused, shell-based tool to run GitHub Actions steps locally using Docker. Perfect for testing workflows without committing or dealing with GitHub secrets and releases.

## Features

- **TUI-inspired Output**: Clean, color-coded terminal interface.
- **Privacy Focused**: Automatically detects and skips steps that reference GitHub secrets (`${{ secrets... }}`) or `github.token`.
- **Debug Mode**: Enable verbose debugging with `DEBUG=true`.
- **Lightweight**: Minimal dependencies (`yq`, `docker`).

## Quick Setup (One-liner)

```bash
curl -sSL https://raw.githubusercontent.com/the-abra/local-actions/main/install.sh | bash
```

## Manual Installation

```bash
git clone https://github.com/the-abra/local-actions.git
cd local-actions
chmod +x laction
sudo ln -sf $(pwd)/laction /usr/local/bin/laction
```

## Usage

```bash
laction <workflow-file> <docker-image> [job-name]
```

### Example

```bash
laction examples/ci.yml ubuntu:latest
```

### Debugging

To see raw step data and execution details:
```bash
DEBUG=true laction examples/ci.yml ubuntu:latest
```

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License

MIT License. See [LICENSE](LICENSE) for details.
