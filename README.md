# iOS Showcase

[![CI](https://github.com/mkdigitalsk/ios-showcase/actions/workflows/ci.yml/badge.svg)](https://github.com/mkdigitalsk/ios-showcase/actions/workflows/ci.yml)

Swift 6 · SwiftUI · Observation · SwiftData · XcodeGen · Swift Testing · swift-snapshot-testing · Maestro.

A production-ready native iOS demo app showcasing modern Apple development with SwiftUI, Observation and
SwiftData, screen by screen against a live API: sign-in and sign-up, remote notes with etag conflicts, a
local SwiftData database, platform APIs (share, dial, mail, clipboard, location, Face ID), a code scanner,
a date-range calendar, local and push notifications, and settings with a profile photo, theme, language
and account deletion — covered by unit, snapshot and Maestro end-to-end tests. Every screen is in
[docs/screens.md](docs/screens.md).

```shell
make hooks     # once
make project   # after adding or removing files
make build
make test
```

Simulator runs (`scripts/run-device.sh`) and the Maestro suite (`scripts/run-e2e.py`) read a gitignored
`local.properties` — copy `local.properties.example` and set `run.device=true`.
