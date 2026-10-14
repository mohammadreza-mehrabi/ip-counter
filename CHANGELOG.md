# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- JSON output format
- CSV export
- GeoIP lookup
- Time-based analysis
- Email alerts

## [1.0.0] - 2026-10-12

### Added
- Initial release
- Parse SSH authentication logs
- Detect brute-force attacks by IP
- Username analysis
- Strict IPv4 validation
- Color-coded output (red/yellow/green)
- Configurable thresholds via config file
- CLI options: -t, -n, -o, -h
- Top N filtering
- Save reports to file
- Exit codes for automation
- Unit tests with bats
- CI with GitHub Actions

### Security
- Input validation for IP addresses
- File existence checks
- Sanitized error messages

## [0.1.0] - 2026-10-01

### Added
- Initial prototype
- Basic IP counting
- Simple output format

[Unreleased]: https://github.com/YOUR_USERNAME/ip-counter/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/YOUR_USERNAME/ip-counter/compare/v0.1.0...v1.0.0
[0.1.0]: https://github.com/YOUR_USERNAME/ip-counter/releases/tag/v0.1.0
