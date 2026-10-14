#!/bin/bash
# ============================================
# ip-counter — Installer
# ============================================
# Simple installer script.
# For advanced options, use: make install
# ============================================

set -euo pipefail

DEFAULT_PREFIX="/usr/local"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

usage() {
    cat << USAGE_EOF
Usage: $0 [OPTIONS]

Install ip-counter to your system.

Options:
  -p PREFIX    Install prefix (default: $DEFAULT_PREFIX)
  -h           Show this help

Examples:
  $0                     Install to $DEFAULT_PREFIX (may need sudo)
  $0 -p \$HOME/.local     Install to user directory
  sudo $0                Install system-wide

USAGE_EOF
    exit 0
}

PREFIX="$DEFAULT_PREFIX"

while [[ $# -gt 0 ]]; do
    case "$1" in
        -p)
            PREFIX="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            error "Unknown option: $1"
            usage
            ;;
    esac
done

info "Checking prerequisites..."

if [[ ! -f "$SCRIPT_DIR/Makefile" ]]; then
    error "Makefile not found in $SCRIPT_DIR"
    error "Are you running this from the project root?"
    exit 1
fi

if ! command -v make >/dev/null 2>&1; then
    error "'make' is not installed"
    error "Install it with: apt install make"
    exit 1
fi

success "Prerequisites OK"

if [[ "$PREFIX" == /usr/* ]] || [[ "$PREFIX" == /opt/* ]]; then
    if [[ $EUID -ne 0 ]]; then
        error "Installing to $PREFIX requires root privileges"
        error "Try: sudo $0 -p $PREFIX"
        error "Or:  $0 -p \$HOME/.local"
        exit 1
    fi
fi

info "Installing ip-counter to $PREFIX..."
echo ""

cd "$SCRIPT_DIR"
make install PREFIX="$PREFIX"

echo ""
success "Installation complete!"
echo ""

if [[ "$PREFIX" == "$HOME/.local" ]]; then
    warn "Don't forget to add to your PATH:"
    echo ""
    echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
    echo "Add this line to ~/.bashrc or ~/.zshrc"
    echo ""
fi

info "Try it out:"
echo ""
echo "    ${PREFIX}/bin/ip_counter --help"
echo ""
