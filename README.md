# what-is-installed

A small shell tool that shows what command-line tools are actually installed in common user-facing locations.

## Features

- Scans all common install locations by default:
  - `~/.local/bin`
  - `~/.npm-global/bin`
  - `/opt/homebrew/bin`
  - `~/.cargo/bin` (Rust / Cargo)
  - `~/go/bin` (Go install)
  - `~/.local/pipx/venvs` (pipx)
  - `~/miniconda3/bin` (Conda)
  - `~/.local/share/mise/shims` (mise)
  - `~/.asdf/shims` (asdf)
  - `~/Library/pnpm` (pnpm)
  - `/usr/local/bin` (traditional Unix)
- Shows **version info** for every discovered command
- Lists Homebrew formulas, npm global packages, and pip user packages
- Supports `--quiet` mode (only results, no notes)
- Cross-platform: works on macOS and Linux
- Zero external dependencies

## Usage

```bash
./bin/what-is-installed           # default: scan all, show versions
./bin/what-is-installed --quiet   # only show results, no notes
```

## Example Output

```text
[已发现的命令]
python3.11         3.11.15        /Users/you/.local/bin/python3.11
uv                 0.11.8         /Users/you/.local/bin/uv
brew               5.1.5          /opt/homebrew/bin/brew
gh                 2.89.0         /opt/homebrew/bin/gh
docker             29.3.1         /usr/local/bin/docker
node               24.14.0        /usr/local/bin/node
npm                11.9.0         /usr/local/bin/npm

[Homebrew 包]
gh 2.89.0

[npm 全局包]
/Users/you/.npm-global/lib
└── (empty)

[pip 用户包]
Package    Version
---------- -------
pip        25.3
```

## Notes

- Version detection tries `--version` first, then `-V`, with a 1-second timeout per command.
- Use `--quiet` to hide all notes and comments.

## License

MIT
