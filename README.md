# what-is-installed

A small shell tool that shows what command-line tools are actually installed in common user-facing locations.

It is designed to stay readable:

- only shows commands that really exist
- groups output by install source
- supports Chinese and English output
- avoids requiring extra dependencies

## Features

- scans common command locations:
  - `~/.local/bin`
  - `~/.npm-global/bin`
  - `/opt/homebrew/bin`
- lists:
  - discovered executables
  - Homebrew formulas
  - npm global packages
  - pip user packages
  - active `PATH` entries
- supports:
  - `--lang zh`
  - `--lang en`
- auto-detects Chinese when `LANG` or `LC_ALL` starts with `zh`

## Usage

```bash
./bin/what-is-installed
./bin/what-is-installed --lang zh
./bin/what-is-installed --lang en
```

## Example

```text
[Found Commands]
python3.11       /Users/you/.local/bin/python3.11
python3.14       /Users/you/.local/bin/python3.14
uv               /Users/you/.local/bin/uv
uvx              /Users/you/.local/bin/uvx
brew             /opt/homebrew/bin/brew
gh               /opt/homebrew/bin/gh
```

## Notes

- This tool is intentionally conservative. It only scans a few common install locations by default.
- It does not try to guess every possible command on your machine.
- `PATH` output may still include stale directories even when the commands are already gone.

## License

MIT
