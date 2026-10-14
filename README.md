# IP Counter

> A Bash + AWK tool for analyzing SSH logs and detecting brute-force attacks.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Bash-4.0%2B-green.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/Platform-Linux-blue.svg)](https://www.kernel.org/)

## 📖 Overview

**IP Counter** is a lightweight security tool that analyzes SSH authentication logs to detect:

- 🚨 **Brute-force attacks** — identifies IPs with many failed login attempts
- 👤 **Targeted accounts** — shows which usernames are being attacked
- 📊 **Failure rates** — calculates the percentage of failed attempts per IP
- 🎯 **Suspicious activity** — highlights high-risk IPs with color coding

## ✨ Features

- ✅ Parse SSH logs (`/var/log/auth.log`, `/var/log/secure`)
- ✅ Validate IP addresses (strict IPv4 validation)
- ✅ Color-coded output (🔴 red / 🟡 yellow / 🟢 green)
- ✅ Configurable thresholds (via config file or CLI)
- ✅ Top N filtering
- ✅ Save reports to file
- ✅ Exit codes for automation
- ✅ Zero dependencies (pure Bash)

## 🔧 Requirements

- **Bash** 4.0 or higher
- **GNU coreutils** (`sort`, `head`, `tee`)
- **Linux** (tested on Debian, Ubuntu, Kali)

## 📦 Installation

### From source

```bash
git clone https://github.com/YOUR_USERNAME/ip-counter.git
cd ip-counter
make install
```

Default install location: `/usr/local/bin/ip_counter`

### Custom prefix

```bash
make install PREFIX=$HOME/.local
```

Then add to your `~/.bashrc`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

### Uninstall

```bash
make uninstall
```

## 🚀 Usage

### Basic

```bash
ip_counter /var/log/auth.log
```

### Show help

```bash
ip_counter -h
```

### With threshold

```bash
ip_counter /var/log/auth.log -t 3
```

Only show IPs with **3 or more** failed attempts.

### With Top N

```bash
ip_counter /var/log/auth.log -n 5
```

Only show the **top 5** IPs.

### Combined

```bash
ip_counter /var/log/auth.log -t 2 -n 10
```

### Save to file

```bash
ip_counter /var/log/auth.log -o report.txt
```

## 📊 Sample Output

```text
============================================
 IP Counter — SSH Failed Login Report
============================================
 Log File  : /var/log/auth.log
 Threshold : 1
============================================

========== Failed Login Attempts by IP ==========
203.0.113.42       6 attempts
192.168.1.10       5 attempts
10.0.0.15          3 attempts
8.8.8.8            2 attempts

========== Failed Login Attempts by User ==========
root               8 attempts
admin              7 attempts
test               4 attempts

-------------------------------------------
Total failed attempts : 24
Unique IPs            : 9
Unique users          : 5
```

## ⚙️ Configuration

Edit `config/thresholds.conf`:

```bash
# Color thresholds
COLOR_RED_THRESHOLD=5
COLOR_YELLOW_THRESHOLD=3

# Default threshold for IP filtering
DEFAULT_THRESHOLD=1

# Username analysis
SHOW_USER_ANALYSIS=1
TOP_USERS=10
```

After installation, the config is at `/usr/local/etc/ip-counter/thresholds.conf`.

## 🎯 Exit Codes

| Code | Meaning                                 |
| ---- | --------------------------------------- |
| `0`  | No threats detected (clean)             |
| `1`  | Threats detected (suspicious IPs found) |

### Automation example

```bash
#!/bin/bash
if ! ip_counter /var/log/auth.log -t 5; then
    echo "🚨 ALERT: Suspicious activity detected!"
    # send email, slack notification, etc.
fi
```

## 🗂️ Project Structure

```text
ip-counter/
├── bin/
│   └── ip_counter.sh       # Main script
├── lib/
│   ├── colors.sh           # ANSI color definitions
│   ├── logging.sh          # Logging functions
│   └── validators.sh       # Input validators
├── config/
│   └── thresholds.conf     # Configuration
├── tests/
│   ├── test_ip_counter.bats # Unit tests
│   └── fixtures/
│       └── ssh.log         # Sample log
├── docs/
│   ├── usage.md
│   └── examples.md
├── Makefile
├── LICENSE
└── README.md
```

## 🧪 Testing

```bash
make test
```

Requires [bats](https://github.com/bats-core/bats-core).

## 🧹 Development

### Lint

```bash
make lint
```

Requires [shellcheck](https://www.shellcheck.net/).

### Clean

```bash
make clean
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing`)
3. Commit changes (`git commit -am 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing`)
5. Open a Pull Request

## 📜 License

This project is licensed under the **MIT License** — see [LICENSE](LICENSE) file for details.

## 👤 Author

**MohammadReza Mehrabi**

- GitHub: [@YOUR_USERNAME](https://github.com/YOUR_USERNAME)

## ⭐ Show your support

If this project helped you, please give it a ⭐️!

## 🙏 Acknowledgments

- Inspired by `fail2ban` and similar security tools
- Built with ❤️ using pure Bash

---

**⚠️ Disclaimer:** This tool is for **educational purposes** and **authorized security testing** only. Use it only on systems you own or have explicit permission to test.
