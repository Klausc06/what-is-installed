# shellcheck shell=bash
# lib/platform/linux.sh — Linux platform support

get_system_dirs() {
  printf '%s' '^(/bin|/sbin|/usr/bin|/usr/sbin|/lib/systemd/)'
}

get_family_skip_patterns() {
  printf '%s' '.*-(x86_64|aarch64|i686|armv7l|armhf)$'
}

get_gui_skip_patterns() {
  # Known GUI-only executables found in /usr/bin on common Linux desktops.
  # Probing these would launch their main window — skip them.
  printf '%s' '^(xdg-open|notify-send|zenity|kdialog|gvfs-open|gvfs-mount|gvfs-set-attribute|gvfs-copy|gvfs-move|gvfs-rm|gvfs-mkdir|gvfs-monitor-dir|gvfs-monitor-file|gvfs-ls|gvfs-info|gvfs-cat|gvfs-tree|gvfs-save|gnome-open|kde-open|exo-open|gvfsd|gvfsd-metadata|gnome-terminal|konsole|xterm|gucharmap|gnome-calculator|baobab|eog|evince|gedit|gnome-text-editor|nautilus|totem|yelp|systemctl|journalctl)$'
}

section_label() {
  case "$1" in
    */.local/bin)      printf '%s' 'User Local' ;;
    */.npm-global/bin) printf '%s' 'npm Global' ;;
    */usr/local/bin|*/usr/local/sbin) printf '%s' 'System Local' ;;
    */snap/bin)         printf '%s' 'Snap' ;;
    */linuxbrew/*/bin)  printf '%s' 'Homebrew' ;;
    */.cargo/bin)      printf '%s' 'Cargo' ;;
    */go/bin)          printf '%s' 'Go' ;;
    */.nvm/versions/*/bin) printf '%s' 'nvm' ;;
    */.pyenv/versions/*/bin|*/.pyenv/shims) printf '%s' 'pyenv' ;;
    */.deno/bin)       printf '%s' 'Deno' ;;
    */.nix-profile/bin|/nix/var/nix/profiles/*/bin) printf '%s' 'Nix' ;;
    *)                 printf '%s' 'Other' ;;
  esac
}

section_color() {
  case "$1" in
    'User Local')       printf '%s%s' "$C_GREEN" "$C_BOLD" ;;
    'npm Global')        printf '%s%s' "$C_YELLOW" "$C_BOLD" ;;
    'Homebrew')          printf '%s%s' "$C_CYAN" "$C_BOLD" ;;
    'Snap')              printf '%s%s' "$C_MAGENTA" "$C_BOLD" ;;
    'System Local')      printf '%s%s' "$C_DIM" "$C_BOLD" ;;
    'Cargo')             printf '%s%s' "$C_YELLOW" "$C_BOLD" ;;
    'Go')                printf '%s%s' "$C_CYAN" "$C_BOLD" ;;
    'nvm')               printf '%s%s' "$C_GREEN" "$C_BOLD" ;;
    'pyenv')             printf '%s%s' "$C_BLUE" "$C_BOLD" ;;
    'Deno')              printf '%s%s' "$C_GREEN" "$C_BOLD" ;;
    'Nix')               printf '%s%s' "$C_BLUE" "$C_BOLD" ;;
    *)                   printf '%s%s' "$C_RESET" "$C_BOLD" ;;
  esac
}

