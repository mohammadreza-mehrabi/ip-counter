#!/bin/bash
# ============================================
# validators.sh — Input validation functions
# ============================================
is_valid_ip() {
  local ip="$1"
  local octet='(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'
  local regex="^(${octet}\.){3}${octet}$"
  [[  "$ip" =~ $regex  ]]
}
is_valid_file() {
  local file="$1"
  [[ -f "$file" && -r "$file"  ]]
}
is_positive_int(){
  local num="$1"
  [[  "$num" =~ ^[1-9][0-9]*$  ]]
}
is_non_negative_int() {
  local num="$1"
  [[  "$num" =~ ^[0-9]+$  ]]
}
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

