# ============================================
# ip-counter Makefile
# ============================================

PREFIX ?= /usr/local
BINDIR := $(PREFIX)/bin
LIBDIR := $(PREFIX)/lib/ip-counter
CONFIGDIR := $(PREFIX)/etc/ip-counter

.PHONY: all install uninstall test lint clean help

all: lint test

help:
	@echo "Available targets:"
	@echo "  make install     Install to $(PREFIX)"
	@echo "  make uninstall   Remove installation"
	@echo "  make test        Run unit tests"
	@echo "  make lint        Run shellcheck"
	@echo "  make clean       Remove generated files"
	@echo "  make help        Show this help"

install:
	@echo "Installing ip-counter to $(PREFIX)..."
	install -d $(DESTDIR)$(BINDIR)
	install -d $(DESTDIR)$(LIBDIR)
	install -d $(DESTDIR)$(CONFIGDIR)
	install -m 755 bin/ip_counter.sh $(DESTDIR)$(BINDIR)/ip_counter
	install -m 644 lib/*.sh $(DESTDIR)$(LIBDIR)/
	install -m 644 config/*.conf $(DESTDIR)$(CONFIGDIR)/
	@echo "✅ Installation complete!"
	@echo "Run: ip_counter --help"

uninstall:
	@echo "Removing ip-counter from $(PREFIX)..."
	rm -f $(DESTDIR)$(BINDIR)/ip_counter
	rm -rf $(DESTDIR)$(LIBDIR)
	rm -rf $(DESTDIR)$(CONFIGDIR)
	@echo "✅ Uninstallation complete!"

test:
	@echo "Running unit tests..."
	@if command -v bats >/dev/null 2>&1; then \
		bats tests/; \
	else \
		echo "⚠️  bats not installed. Install: apt install bats"; \
	fi

lint:
	@echo "Running shellcheck..."
	@if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck bin/ip_counter.sh lib/*.sh; \
	else \
		echo "⚠️  shellcheck not installed. Install: apt install shellcheck"; \
	fi

clean:
	@echo "Cleaning up..."
	rm -f report_*.txt
	find . -name "*.tmp" -delete
	@echo "✅ Cleaned!"
