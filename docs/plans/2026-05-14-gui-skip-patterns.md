# GUI Skip Patterns — Implementation Plan

> **For Hermes:** Execute directly, no subagent needed (3 files, ~10 lines each).

**Goal:** Add GUI-tool skip filter to Pass 1 candidate collection, preventing `what-is-installed` from launching GUI application windows during version probing. Windows blacklist is already in place; this plan completes the remaining platforms.

**Architecture:** Each platform file exports a regex via `get_gui_skip_patterns()`. Main script reads it once into `GUI_SKIP` and checks every candidate name against it in Pass 1. Tools matching the regex are silently dropped before version probing.

**Tech Stack:** Bash 3.2+, POSIX regex, existing project structure

---

### Task 1: Add `get_gui_skip_patterns()` to linux.sh

**Objective:** Define Linux GUI-only executable patterns

**Files:**
- Modify: `lib/platform/linux.sh` (after `get_family_skip_patterns`)

**Step 1: Insert function**

After `get_family_skip_patterns()` closing `}`, add:

```bash
get_gui_skip_patterns() {
  # Known GUI-only executables found in /usr/bin on common Linux desktops.
  # Probing these would launch their main window — skip them.
  printf '%s' '^(xdg-open|notify-send|zenity|kdialog|gvfs-open|gvfs-mount|gvfs-set-attribute|gvfs-copy|gvfs-move|gvfs-rm|gvfs-mkdir|gvfs-monitor-dir|gvfs-monitor-file|gvfs-ls|gvfs-info|gvfs-cat|gvfs-tree|gvfs-save|gnome-open|kde-open|exo-open|gvfsd|gvfsd-metadata|gnome-terminal|konsole|xterm|gucharmap|gnome-calculator|baobab|eog|evince|gedit|gnome-text-editor|nautilus|totem|yelp|systemctl|journalctl)$'
}
```

**Step 2: Verify syntax**

```bash
bash -n lib/platform/linux.sh
```

**Step 3: Commit**

```bash
git add lib/platform/linux.sh
git commit -m "feat: add GUI skip patterns for Linux platform"
```

---

### Task 2: Add `get_gui_skip_patterns()` to bsd.sh

**Objective:** Define BSD GUI-only executable patterns

**Files:**
- Modify: `lib/platform/bsd.sh` (after `get_family_skip_patterns`)

**Step 1: Insert function**

After `get_family_skip_patterns()` closing `}`, add:

```bash
get_gui_skip_patterns() {
  # BSD base systems have few GUI tools in PATH.
  # Primarily X11 utilities and desktop-environment launchers.
  printf '%s' '^(xdg-open|notify-send|zenity|xterm|xclock|xlogo|xeyes|xcalc|xedit|xman|xclipboard|startx|xinit|gvfs-open)$'
}
```

**Step 2: Verify syntax**

```bash
bash -n lib/platform/bsd.sh
```

**Step 3: Commit**

```bash
git add lib/platform/bsd.sh
git commit -m "feat: add GUI skip patterns for BSD platform"
```

---

### Task 3: Wire GUI_SKIP into Pass 1

**Objective:** Call `get_gui_skip_patterns()` from main script and apply filter in Pass 1 candidate collection

**Files:**
- Modify: `bin/what-is-installed` (lines ~57 and ~85)

**Step 1: Add GUI_SKIP variable initialization**

After line ~57 (`FAMILY_SKIP=...`), add:

```bash
GUI_SKIP="$(get_gui_skip_patterns)"
```

**Step 2: Add GUI skip check in Pass 1 inner loop**

After the `FAMILY_SKIP` check (line ~92), add:

```bash
    # GUI-only tool skip (prevents launching windows)
    [[ -n "$GUI_SKIP" && "$name" =~ $GUI_SKIP ]] && continue
```

The resulting block should look like:

```bash
    # Architecture suffix skip
    [[ -n "$FAMILY_SKIP" && "$name" =~ $FAMILY_SKIP ]] && continue

    # GUI-only tool skip (prevents launching windows)
    [[ -n "$GUI_SKIP" && "$name" =~ $GUI_SKIP ]] && continue

    # Blocklist patterns
    case "$name" in
```

**Step 3: Verify syntax**

```bash
bash -n bin/what-is-installed
```

**Step 4: Test on macOS (GUI_SKIP is empty string, should have zero effect)**

```bash
time bash bin/what-is-installed 2>/dev/null | wc -l
# Expected: 273, same as before, ~4.5s
```

**Step 5: Commit**

```bash
git add bin/what-is-installed
git commit -m "feat: wire GUI skip filter into Pass 1 candidate collection"
```

---

### Task 4: Verify cross-platform behavior

**Objective:** Confirm macOS/BSD empty patterns don't break anything, Linux/Windows patterns filter correctly

**Quick checks:**

```bash
# macOS: GUI_SKIP is empty, no tools filtered
bash -c "source lib/platform/macos.sh; get_gui_skip_patterns"
# Expected: (empty output)

# Linux: GUI_SKIP has patterns
bash -c "source lib/platform/linux.sh; get_gui_skip_patterns"
# Expected: ^(xdg-open|notify-send|...

# BSD: GUI_SKIP has patterns
bash -c "source lib/platform/bsd.sh; get_gui_skip_patterns"
# Expected: ^(xdg-open|notify-send|...

# Windows: GUI_SKIP has patterns
bash -c "source lib/platform/windows.sh; get_gui_skip_patterns"
# Expected: ^(SvtAv1EncApp|notepad|...
```

---

## Summary

| Platform | GUI patterns added | Risk of missing |
|----------|-------------------|-----------------|
| macOS    | none (empty)      | Low — most macOS GUI tools live in /Applications/*.app, not in PATH |
| Linux    | ~30 patterns      | Medium — users may have GUI tools in ~/.local/bin |
| BSD      | ~9 patterns       | Low — few GUI tools in base system PATH |
| Windows  | ~40 patterns      | Already done in previous commit |

**Post-merge validation:** Run `what-is-installed` on each platform with a real PATH and confirm no GUI windows pop up. If any are missed, add them to the platform-specific regex.
