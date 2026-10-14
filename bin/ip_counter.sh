#!/usr/bin/env bash
# ============================================
# ip_counter.sh — SSH failed login analyzer
# ============================================
# Author:  MohammadReza
# License: MIT
# Version: 1.0.0
# ============================================
set -euo pipefail
# ============================================
# Locate script and load libraries
# ============================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect lib location (dev vs installed)
if [[ -f "${SCRIPT_DIR}/../lib/colors.sh" ]]; then
    # Dev mode: project/lib
    LIB_DIR="${SCRIPT_DIR}/../lib"
elif [[ -f "${SCRIPT_DIR}/../lib/ip-counter/colors.sh" ]]; then
    # Installed mode: PREFIX/lib/ip-counter
    LIB_DIR="${SCRIPT_DIR}/../lib/ip-counter"
else
    # Fallback: system install
    LIB_DIR="/usr/local/lib/ip-counter"
fi

# Detect config location (dev vs installed)
if [[ -f "${SCRIPT_DIR}/../config/thresholds.conf" ]]; then
    CONFIG_DIR="${SCRIPT_DIR}/../config"
elif [[ -f "${SCRIPT_DIR}/../etc/ip-counter/thresholds.conf" ]]; then
    CONFIG_DIR="${SCRIPT_DIR}/../etc/ip-counter"
else
    CONFIG_DIR="/usr/local/etc/ip-counter"
fi
source "${LIB_DIR}/colors.sh"
source "${LIB_DIR}/logging.sh"
source "${LIB_DIR}/validators.sh"
# ============================================
# Load config
# ============================================
CONFIG_FILE="${CONFIG_DIR}/thresholds.conf"
if [[ -f "$CONFIG_FILE"  ]]
then
  source "$CONFIG_FILE"
fi
: "${COLOR_RED_THRESHOLD:=5}"
: "${COLOR_YELLOW_THRESHOLD:=3}"
: "${DEFAULT_THRESHOLD:=1}"
: "${SHOW_USER_ANALYSIS:=1}"
: "${TOP_USERS:=10}"
# ============================================
# Variables
# ============================================
output_file=""
log_file=""
threshold="$DEFAULT_THRESHOLD"
total=0
shown_count=0
top_n=0
declare -A failed_user=()
declare -A failed_ip=()
# ============================================
# Usage
# ============================================
usage() {
  local exit_code="${1:-0}"
    cat << EOF
Usage: $0 <log_file> [OPTIONS]

A security tool to analyze SSH logs for failed login attempts.

Options:
  -t N    Minimum failed attempts threshold (default: $DEFAULT_THRESHOLD)
  -n N    Show top N results only (default: all)
  -o FILE Save report to file
  -h      Show this help

Examples:
  $0 ssh.log
  $0 ssh.log -t 3
  $0 ssh.log -t 3 -n 5
  $0 ssh.log -o report.txt

EOF
    exit "$exit_code"
}
# ============================================
# Parse arguments
# ============================================
while [[ $# -gt 0 ]]; do
    case "$1" in
        -t)
            threshold="$2"
            shift 2
            ;;
        -n)
            top_n="$2"
            shift 2
            ;;
        -o)
            output_file="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        -*)
            log_error "Unknown option: $1"
            usage 1
            ;;
        *)
            if [[ -z "$log_file" ]]; then
                log_file="$1"
            else
                log_error "Multiple log files not supported"
                exit 1
            fi
            shift
            ;;
    esac
done
# ============================================
# Validate input
# ============================================
if [[ -z "$log_file" ]]; then
    log_error "No log file provided"
    usage 1
fi

if ! is_valid_file "$log_file"; then
    log_error "File not found or not readable: $log_file"
    exit 1
fi

if ! is_positive_int "$threshold"; then
    log_error "Threshold must be a positive integer"
    exit 1
fi
# ============================================
# Setup output
# ============================================
if [[ -n "$output_file" ]]; then
    exec > >(tee "$output_file")
fi
# ============================================
# Main analysis
# ============================================
while IFS= read -r line; do
    if [[ "$line" != *"Failed password"* ]]; then
        continue
    fi
    
    if [[ "$line" =~ from\ ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+) ]]; then
        ip="${BASH_REMATCH[1]}"
        
        if is_valid_ip "$ip"; then
            ((failed_ip["$ip"] = ${failed_ip["$ip"]:-0} + 1))
            
            if [[ "$line" =~ for\ (invalid\ user\ )?([a-zA-Z0-9_-]+)\ from ]]; then
                user="${BASH_REMATCH[2]}"
                ((failed_user["$user"] = ${failed_user["$user"]:-0} + 1))
            fi
        fi
    fi
done < "$log_file"
# ============================================
# Output: Header
# ============================================
echo ""
echo "============================================"
echo -e " ${BOLD}IP Counter — SSH Failed Login Report${NC}"
echo "============================================"
echo " Log File  : $log_file"
echo " Threshold : $threshold"
if (( top_n > 0 )); then
    echo " Top N     : $top_n"
fi
echo "============================================"
echo ""
# ============================================
# Output: IPs
# ============================================
echo "========== Failed Login Attempts by IP =========="

if [[ ${#failed_ip[@]} -eq 0 ]]; then
    echo "No failed attempts found."
    exit 0
fi

for ip in "${!failed_ip[@]}"; do
    if (( failed_ip["$ip"] >= threshold )); then
        if (( failed_ip["$ip"] >= COLOR_RED_THRESHOLD )); then
            color="$RED"
        elif (( failed_ip["$ip"] >= COLOR_YELLOW_THRESHOLD )); then
            color="$YELLOW"
        else
            color="$GREEN"
        fi
        printf "${color}%-18s %d attempts${NC}\n" "$ip" "${failed_ip[$ip]}"
    fi
done | sort -k2 -rn | {
    if (( top_n > 0 )); then
        head -n "$top_n"
    else
        cat
    fi
}
# ============================================
# Compute totals
# ============================================
for ip in "${!failed_ip[@]}"; do
    if (( failed_ip["$ip"] >= threshold )); then
        ((shown_count += 1))
        ((total += failed_ip["$ip"]))
    fi
done
# ============================================
# Output: Users
# ============================================
if (( SHOW_USER_ANALYSIS == 1 )); then
    echo ""
    echo "========== Failed Login Attempts by User =========="
    
    if [[ ${#failed_user[@]} -eq 0 ]]; then
        echo "No user data found."
    else
        for user in "${!failed_user[@]}"; do
            printf "%-18s %d attempts\n" "$user" "${failed_user[$user]}"
        done | sort -k2 -rn | {
            if (( TOP_USERS > 0 )); then
                head -n "$TOP_USERS"
            else
                cat
            fi
        }
    fi
fi
# ============================================
# Output: Summary
# ============================================
echo ""
echo "-------------------------------------------"
echo "Total failed attempts : $total"
echo "Unique IPs            : $shown_count"
echo "Unique users          : ${#failed_user[@]}"
# ============================================
# Exit code
# ============================================
if (( shown_count > 0 )); then
    exit 1
else
    exit 0
fi

