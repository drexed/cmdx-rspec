# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2025-11-09

### Added
- Added mock and stub helpers

### Changed
- Renamed `have_been_success` to `be_successful`
- Renamed `have_been_failure` to `have_failed`
- Renamed `have_been_skipped` to `have_skipped`
- Moved matchers to be within the `lib/rspec/matchers` directory

## [0.2.0] - 2025-09-13

### Added
- Added `have_empty_metadata` and `have_matching_metadata` matchers

### Changed
- Metadata matching must be done via the methods above instead of the fault matchers

## [0.1.0] - 2025-08-24

- Initial release
