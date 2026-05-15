# shellcheck shell=bash
setup_glyphs() {
  if [[ -n "$ASCII_MODE" ]]; then
    B_TL='+' B_TR='+' B_BL='+' B_BR='+'
    B_H='-'  B_V='|' B_CL='+' B_CR='+'
    B_CM='+' B_BM='+'
  else
    B_TL='┌' B_TR='┐' B_BL='└' B_BR='┘'
    B_H='─'  B_V='│' B_CL='├' B_CR='┤'
    B_CM='┼' B_BM='┴'
  fi
}

setup_colors() {
  if [[ -n "$NO_COLOR" ]] || [[ ! -t 1 ]]; then
    C_RESET='' C_BOLD='' C_DIM='' C_CYAN='' C_GREEN='' C_YELLOW='' C_BLUE='' C_MAGENTA=''
  else
    C_RESET=$'\033[0m'
    C_BOLD=$'\033[1m'
    C_DIM=$'\033[2m'
    C_CYAN=$'\033[36m'
    C_GREEN=$'\033[32m'
    C_YELLOW=$'\033[33m'
    C_BLUE=$'\033[34m'
    C_MAGENTA=$'\033[35m'
  fi
}

terminal_width() {
  local w
  w=$(tput cols 2>/dev/null) || w=80
  [[ $w -gt 120 ]] && w=120
  printf '%d' "$w"
}

ver_color() {
  if [[ "$1" =~ ^[0-9]+\.[0-9]+ ]]; then
    printf '%s' "$C_GREEN"
  else
    printf '%s' "$C_YELLOW"
  fi
}

json_escape() {
  local value="$1" out="" i=0 char
  while [[ $i -lt ${#value} ]]; do
    char="${value:$i:1}"
    case "$char" in
      '\') out+='\\' ;;
      '"') out+='\"' ;;
      $'\n') out+='\n' ;;
      $'\r') out+='\r' ;;
      $'\t') out+='\t' ;;
      $'\b') out+='\b' ;;
      $'\f') out+='\f' ;;
      *) out+="$char" ;;
    esac
    i=$((i + 1))
  done
  printf '%s' "$out"
}

csv_field() {
  local value="$1"
  if [[ "$value" == *','* || "$value" == *'"'* || "$value" == *$'\n'* || "$value" == *$'\r'* ]]; then
    printf '"%s"' "${value//\"/\"\"}"
  else
    printf '%s' "$value"
  fi
}

render_table() {
  local num_sections=${#ALL_SECTION_DIRS[@]}
  local i si label start count j entry ename ever epath sp
  local max_name=4 max_ver=7 max_path=4 table_width header_text pad_left pad_right scolor

  if [[ $num_sections -eq 0 ]]; then
    printf '\n  %sNo tools found in non-system PATH directories.%s\n\n' "$C_DIM" "$C_RESET"
    exit 0
  fi

  local -a _short_paths=()
  for i in "${!ALL_SECTION_ITEMS[@]}"; do
    IFS='|' read -r ename ever epath <<< "${ALL_SECTION_ITEMS[$i]}"
    [[ ${#ename} -gt $max_name ]] && max_name=${#ename}
    [[ ${#ever}  -gt $max_ver  ]] && max_ver=${#ever}
    sp="$(short_path "$epath")"
    [[ ${#sp} -gt $max_path ]] && max_path=${#sp}
    _short_paths+=("$sp")
  done

  table_width=$(( 2 + max_name + 3 + max_ver + 3 + max_path + 2 ))

  printf '\n'

  for si in "${!ALL_SECTION_DIRS[@]}"; do
    label="${ALL_SECTION_DIRS[$si]}"
    start="${ALL_SECTION_START[$si]}"
    count="${ALL_SECTION_COUNTS[$si]}"

    scolor="$(section_color "$label")"
    header_text=" $label "
    header_len=${#header_text}
    pad_left=$(( (table_width - header_len) / 2 ))
    pad_right=$(( table_width - header_len - pad_left ))

    printf '%s' "$C_DIM"
    printf '%s%s%s%s%s%s\n' \
      "$B_TL" \
      "$(repeat_char "$B_H" "$pad_left")" \
      "$scolor$header_text$C_DIM" \
      "$(repeat_char "$B_H" "$pad_right")" \
      "$B_TR" \
      "$C_RESET"

    printf '%s' "$C_DIM$B_V$C_RESET "
    printf '%s%-*s%s' "$C_BOLD" "$max_name" "Name" "$C_RESET"
    printf ' %s ' "$C_DIM$B_V$C_RESET"
    printf '%s%-*s%s' "$C_BOLD" "$max_ver" "Version" "$C_RESET"
    printf ' %s ' "$C_DIM$B_V$C_RESET"
    printf '%-*s' "$max_path" "Path"
    printf ' %s\n' "$C_DIM$B_V$C_RESET"

    printf '%s%s%s%s%s%s%s\n' \
      "$C_DIM$B_CL" \
      "$(repeat_char "$B_H" $((max_name + 2)))" \
      "$B_CM" \
      "$(repeat_char "$B_H" $((max_ver + 2)))" \
      "$B_CM" \
      "$(repeat_char "$B_H" $((max_path + 2)))" \
      "$B_CR$C_RESET"

    for ((j = start; j < start + count; j++)); do
      IFS='|' read -r ename ever epath <<< "${ALL_SECTION_ITEMS[$j]}"
      sp="${_short_paths[$j]}"

      printf '%s ' "$C_DIM$B_V$C_RESET"
      printf '%s%-*s%s' "$C_BOLD" "$max_name" "$ename" "$C_RESET"
      printf ' %s ' "$C_DIM$B_V$C_RESET"
      printf '%s%-*s%s' "$(ver_color "$ever")" "$max_ver" "$ever" "$C_RESET"
      printf ' %s ' "$C_DIM$B_V$C_RESET"
      printf '%s%-*s%s' "$C_DIM" "$max_path" "$sp" "$C_RESET"
      printf ' %s\n' "$C_DIM$B_V$C_RESET"
    done

    printf '%s%s%s%s%s%s%s\n' \
      "$C_DIM$B_BL" \
      "$(repeat_char "$B_H" $((max_name + 2)))" \
      "$B_BM" \
      "$(repeat_char "$B_H" $((max_ver + 2)))" \
      "$B_BM" \
      "$(repeat_char "$B_H" $((max_path + 2)))" \
      "$B_BR$C_RESET"

    printf '\n'
  done
}
