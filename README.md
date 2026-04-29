# what-is-installed

A small shell tool that shows what command-line tools are actually installed in common user-facing locations.

It is designed to stay readable:

- only shows commands that really exist
- groups output by install source
- supports Chinese and English output
- avoids requiring extra dependencies
- shows version info when requested

## Features

- scans common command locations:
  - `~/.local/bin`
  - `~/.npm-global/bin`
  - `/opt/homebrew/bin`
- **extended scan** (`--all`) also covers:
  - `~/.cargo/bin` (Rust / Cargo)
  - `~/go/bin` (Go install)
  - `~/.local/pipx/venvs` (pipx)
  - `~/miniconda3/bin` (Conda)
  - `~/.local/share/mise/shims` (mise)
  - `~/.asdf/shims` (asdf)
  - `~/Library/pnpm` (pnpm)
  - `/usr/local/bin` (traditional Unix)
- lists:
  - discovered executables
  - **version info** (with `--version`)
  - Homebrew formulas
  - npm global packages
  - pip user packages
  - active `PATH` entries
- supports:
  - `--lang zh`
  - `--lang en`
  - `--version` (show command versions)
  - `--all` (extended directory scan)
  - `--quiet` (only show results, no notes)
- auto-detects Chinese when `LANG` or `LC_ALL` starts with `zh`
- cross-platform: works on macOS and Linux (with or without `timeout`/`gtimeout`)

## Usage

```bash
./bin/what-is-installed
./bin/what-is-installed --lang zh
./bin/what-is-installed --lang en
./bin/what-is-installed --version          # show version info for each command
./bin/what-is-installed --all              # scan extended directories
./bin/what-is-installed --all --version    # combine both
./bin/what-is-installed --quiet            # only show results, no notes
./bin/what-is-installed --quiet --version  # clean output with versions
```

## Examples

### Default mode

```text
[Found Commands]
python3.11       /Users/you/.local/bin/python3.11
python3.14       /Users/you/.local/bin/python3.14
uv               /Users/you/.local/bin/uv
uvx              /Users/you/.local/bin/uvx
brew             /opt/homebrew/bin/brew
gh               /opt/homebrew/bin/gh
```

### With version info (`--version`)

```text
[Found Commands]
python3.11         3.11.15        /Users/you/.local/bin/python3.11
python3.14         3.14.4         /Users/you/.local/bin/python3.14
uv                 0.11.8         /Users/you/.local/bin/uv
uvx                0.11.8         /Users/you/.local/bin/uvx
brew               5.1.5          /opt/homebrew/bin/brew
gh                 2.89.0         /opt/homebrew/bin/gh
```

### Quiet mode (`--quiet`)

```text
[概览]
用户命令目录 /Users/you/.local/bin
npm 全局目录  /Users/you/.npm-global/bin
Homebrew 目录 /opt/homebrew/bin

[已发现的命令]
python3.11         3.11.15        /Users/you/.local/bin/python3.11
uv                 0.11.8         /Users/you/.local/bin/uv
brew               5.1.5          /opt/homebrew/bin/brew
gh                 2.89.0         /opt/homebrew/bin/gh

[Homebrew 包]
gh 2.89.0

[npm 全局包]
/Users/you/.npm-global/lib
└── (empty)

[pip 用户包]
```

## Notes

- This tool is intentionally conservative. It only scans a few common install locations by default.
- Use `--all` to scan extended directories (cargo, go, pipx, conda, mise, asdf, pnpm, etc.).
- Use `--quiet` to hide all notes and comments, showing only scan results.
- Version detection tries `--version` first, then `-V`, with a 1-second timeout per command.
- `PATH` output may still include stale directories even when the commands are already gone.

## License

MIT
