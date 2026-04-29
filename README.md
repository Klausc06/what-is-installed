# what-is-installed

A small shell tool that shows what command-line tools are actually available in your `$PATH`.

## Features

- **Dynamically scans all directories in `$PATH`** — no hardcoded list to maintain
- Shows **version info** for every discovered command
- Lists Homebrew formulas, npm global packages, and pip user packages
- Cross-platform: works on macOS and Linux
- Zero external dependencies

## Usage

```bash
./bin/what-is-installed
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

## How it works

1. Reads your `$PATH` environment variable
2. For each directory in `$PATH`, finds all executable files
3. Tries `--version` (or `-V` as fallback) on each command
4. Extracts the version number using regex
5. Deduplicates identical paths (same file in multiple `$PATH` entries)
6. Caches version results (same command name only checked once)

## License

MIT
