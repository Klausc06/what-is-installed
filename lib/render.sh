# shellcheck shell=bash
# Reserved: render_json, render_csv, render_plain, dispatch_render are
# not currently called (render_table is used directly) but kept for future use.
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
    C_RESET='' C_BOLD='' C_DIM='' C_CYAN='' C_GREEN='' C_YELLOW='' C_BLUE='' C_MAGENTA='' C_RED=''
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
  local si label start count j entry ename ever epath sp
  local max_name max_ver max_path table_width header_text pad_left pad_right scolor

  if [[ $num_sections -eq 0 ]]; then
    printf '\n  %sNo tools found in non-system PATH directories.%s\n\n' "$C_DIM" "$C_RESET"
    exit 0
  fi

  printf '\n'

  for si in "${!ALL_SECTION_DIRS[@]}"; do
    label="${ALL_SECTION_DIRS[$si]}"
    start="${ALL_SECTION_START[$si]}"
    count="${ALL_SECTION_COUNTS[$si]}"

    max_name=4
    max_ver=7
    max_path=4

    for ((j = start; j < start + count; j++)); do
      entry="${ALL_SECTION_ITEMS[$j]}"
      IFS='|' read -r ename ever epath <<< "$entry"
      [[ ${#ename} -gt $max_name ]] && max_name=${#ename}
      [[ ${#ever}  -gt $max_ver  ]] && max_ver=${#ever}
      sp="$(short_path "$epath")"
      [[ ${#sp} -gt $max_path ]] && max_path=${#sp}
    done

    table_width=$(( 2 + max_name + 3 + max_ver + 3 + max_path + 2 ))

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
      entry="${ALL_SECTION_ITEMS[$j]}"
      IFS='|' read -r ename ever epath <<< "$entry"
      sp="$(short_path "$epath")"

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

render_json() {
  local si j start count entry ename ever epath label
  local first=true

  printf '['
  for si in "${!ALL_SECTION_DIRS[@]}"; do
    label="${ALL_SECTION_DIRS[$si]}"
    start="${ALL_SECTION_START[$si]}"
    count="${ALL_SECTION_COUNTS[$si]}"
    for ((j = start; j < start + count; j++)); do
      entry="${ALL_SECTION_ITEMS[$j]}"
      IFS='|' read -r ename ever epath <<< "$entry"
      if [[ "$first" != true ]]; then
        printf ','
      fi
      first=false
      printf '\n  {"name":"%s","version":"%s","path":"%s","section":"%s"}' \
        "$(json_escape "$ename")" \
        "$(json_escape "$ever")" \
        "$(json_escape "$epath")" \
        "$(json_escape "$label")"
    done
  done
  printf '\n]\n'
}

render_csv() {
  local si j start count entry ename ever epath label field first

  printf 'Name,Version,Path,Section\n'
  for si in "${!ALL_SECTION_DIRS[@]}"; do
    label="${ALL_SECTION_DIRS[$si]}"
    start="${ALL_SECTION_START[$si]}"
    count="${ALL_SECTION_COUNTS[$si]}"
    for ((j = start; j < start + count; j++)); do
      entry="${ALL_SECTION_ITEMS[$j]}"
      IFS='|' read -r ename ever epath <<< "$entry"
      first=true
      for field in "$ename" "$ever" "$epath" "$label"; do
        if [[ "$first" != true ]]; then
          printf ','
        fi
        first=false
        csv_field "$field"
      done
      printf '\n'
    done
  done
}

render_plain() {
  local max_name=4 max_ver=7 max_path=4
  local si j start count entry ename ever epath

  for si in "${!ALL_SECTION_DIRS[@]}"; do
    start="${ALL_SECTION_START[$si]}"
    count="${ALL_SECTION_COUNTS[$si]}"
    for ((j = start; j < start + count; j++)); do
      entry="${ALL_SECTION_ITEMS[$j]}"
      IFS='|' read -r ename ever epath <<< "$entry"
      [[ ${#ename} -gt $max_name ]] && max_name=${#ename}
      [[ ${#ever}  -gt $max_ver  ]] && max_ver=${#ever}
      [[ ${#epath} -gt $max_path ]] && max_path=${#epath}
    done
  done

  for si in "${!ALL_SECTION_DIRS[@]}"; do
    start="${ALL_SECTION_START[$si]}"
    count="${ALL_SECTION_COUNTS[$si]}"
    for ((j = start; j < start + count; j++)); do
      entry="${ALL_SECTION_ITEMS[$j]}"
      IFS='|' read -r ename ever epath <<< "$entry"
      printf '%-*s  %-*s  %-*s\n' "$max_name" "$ename" "$max_ver" "$ever" "$max_path" "$epath"
    done
  done
}

dispatch_render() {
  case "$OUTPUT_FORMAT" in
    json)  render_json ;;
    csv)   render_csv ;;
    plain) render_plain ;;
    *)     render_table ;;
  esac
}
