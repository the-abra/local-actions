# laction

A simple alternative to `act` — run your project's build, test, and lint steps locally in Docker using a plain `laction.ini` config file.

No GitHub Actions YAML. No runner emulation. Just a profile, an image, and a command.

## Install

```bash
curl -sSL https://raw.githubusercontent.com/the-abra/local-actions/main/install.sh | bash
```

Or manually:

```bash
git clone https://github.com/the-abra/local-actions.git
cd local-actions
sudo ln -sf $(pwd)/laction /usr/local/bin/laction
```

## Usage

```bash
laction [project-path] [profile]
```

| Command | What it does |
|---|---|
| `laction` | runs `[default]` in current directory |
| `laction ./myproject` | runs `[default]` in `./myproject` |
| `laction ./myproject test` | runs `[test]` in `./myproject` |

## laction.ini

Place a `laction.ini` in your project root:

```ini
[default]
image = ubuntu:latest
run = ./scripts/build.sh

[test]
image = ubuntu:latest
run = ./scripts/test.sh

[lint]
image = node:20
run = npm run lint
```

Profile names are arbitrary — but by convention:

| Profile | Purpose |
|---|---|
| `default` | Runs when no profile is specified. Typically a build or sanity check. |
| `build` | Compiles or packages the project. |
| `test` | Runs the test suite. |
| `lint` | Checks code style and formatting. |

You can name profiles anything: `deploy`, `migrate`, `docs`, etc.

Each profile defines an image and a command (or script path) to run inside a temporary container. The project directory is mounted at `/workspace`.

## Container defaults

Each profile runs in a fresh, temporary container with these defaults:

| Setting | Value |
|---|---|
| Volume mount | `<project-dir>` → `/workspace` |
| Working directory | `/workspace` |
| Lifecycle | Removed after run (`--rm`) |
| Shell | `sh -c` |

Your project files are available at `/workspace` inside the container. Scripts referenced in `run` are resolved relative to `/workspace`.

## Output

```
info  profile [test] → ubuntu:latest
info  run: ./scripts/test.sh
───────────────────────────────────────────────────
... container output ...
───────────────────────────────────────────────────
done  Profile 'test' completed.
```

## Debug

```bash
DEBUG=true laction ./myproject test
```

## Requirements

- `docker`
