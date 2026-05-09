# what-is-installed

Scan your `$PATH` and see every CLI tool you have — with versions, grouped by source, in a beautiful table.

No dependencies. Works on macOS, Linux, BSD, and Windows (MinGW/Cygwin). Zero-config.

## Features

- **Dynamic PATH scanning** — no hardcoded lists, reads `$PATH` directly
- **Version detection** — probes `--version` then `-V`, extracts semver, handles encoding fallback
- **Smart deduplication** — same command shown once; family variants (python3.12 / python3) deduplicated
- **Beautiful output** — box-drawing tables with ANSI colors, grouped by source category
- **Multiple formats** — table (default), JSON, CSV, and plain text
- **File cache** — TSV-based cache (1h TTL) speeds up repeat runs; safe parser, no `source` exec
- **Filtering & sorting** — fuzzy filter by name, sort by name/version/path
- **Cross-platform** — macOS, Linux, BSD, MinGW, Cygwin. Bash 3.2+ compatible.
- **System directory filtering** — skips `/bin`, `/sbin`, `/usr/*`, `/System/` by default
- **Timeout protection** — per-command 1s timeout with job-control killer
- **Zero dependencies** — pure Bash, not even `jq`

## Quick Install

```bash
# Clone and symlink into PATH
git clone https://github.com/Klausc06/what-is-installed.git
ln -s "$(pwd)/what-is-installed/bin/what-is-installed" ~/.local/bin/what-is-installed
```

Or use the macOS Finder launcher: double-click `what-is-installed.command` on your Desktop.

## Usage

```
what-is-installed [OPTIONS]

Options:
  --help, -h              Show help
  --no-color              Disable colored output
  --json                  Output as JSON
  --csv                   Output as CSV
  --plain                 Plain text (no box drawing)
  --ascii                 ASCII characters for box drawing
  --filter <pattern>      Only show commands matching pattern (fuzzy, case-insensitive)
  --sort <field>          Sort by: name, version, path (default: name)
  --no-cache              Skip cache, always do fresh version probing
  --include-system, -a    Include system directories in scan
```

### Examples

```bash
# Default: colored table grouped by source
what-is-installed

# Filter to specific tools
what-is-installed --filter docker
what-is-installed --filter py

# Machine-readable output
what-is-installed --json
what-is-installed --csv

# Plain text, no colors, ASCII borders
what-is-installed --plain --no-color --ascii

# Include system tools, sort by version
what-is-installed -a --sort version
```

### Sample Output

```
┌─────────────── Homebrew ────────────────┐
│ Name   │ Version │ Path                 │
├───────┼────────┼─────────────────────┤
│ gh     │ 2.89.0  │ /opt/homebrew/bin/gh │
│ node   │ 24.14.0 │ /opt/homebrew/bin/node│
│ python │ 3.14.0  │ /opt/homebrew/bin/python│
└───────┴────────┴─────────────────────┘

┌─────────────── User Local ───────────────┐
│ Name │ Version │ Path                    │
├─────┼────────┼────────────────────────┤
│ uv   │ 0.11.8  │ ~/.local/bin/uv         │
│ fcc  │ 1.2.3   │ ~/.local/bin/fcc        │
└─────┴────────┴────────────────────────┘
```

## Supported Platforms

| OS | Detection | System dirs filtered |
|----|-----------|---------------------|
| macOS | `Darwin` | `/bin`, `/sbin`, `/usr/*`, `/System/`, `/Library/Apple/` |
| Linux | `Linux` | `/bin`, `/sbin`, `/usr/*`, `/lib/systemd/` |
| BSD | `*BSD` | `/bin`, `/sbin`, `/usr/*`, `/rescue/` |
| MinGW | `MINGW*` | `/c/Windows/` |
| Cygwin | `CYGWIN*` | `/c/Windows/` |

Source categories are auto-detected per platform (Homebrew, Snap, npm Global, Python Framework, etc.).

## How It Works

1. Reads `$PATH`, deduplicates directories while preserving order
2. For each non-system directory, finds executable files
3. Probes `--version` on each command (falls back to `-V`, handles latin1→UTF-8)
4. Extracts semver via regex; marks `-` if undetectable
5. Deduplicates by name + family (e.g. `python3.12` and `python3.11` with same version)
6. Groups results by source category with colored box-drawing tables
7. Caches results to `~/.cache/what-is-installed/versions.cache` (1-hour TTL)

## Architecture

```
bin/what-is-installed     # Main script (353 lines)
lib/platform.sh           # OS detection, system dirs, category labels (79 lines)
lib/render.sh             # Table/JSON/CSV/plain rendering, colors, cache escaping (247 lines)
```

## License

MIT
