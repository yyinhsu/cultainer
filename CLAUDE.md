
# Cultainer - Project Guide

## Overview

Cultainer is a comprehensive cross-platform (iOS / macOS / Web) media consumption tracker and knowledge extraction tool.

## Quick Reference

### Tech Stack
- **Frontend**: Flutter (Dart) + Riverpod
- **Backend**: Firebase (Firestore, Auth, Storage)
- **AI**: Google ML Kit (OCR), Gemini Pro
- **APIs**: Google Books, TMDB, Spotify
- **IDE**: VS Code (development) → Xcode (release signing only)

### Common Commands
```bash
flutter run                    # Run dev build
flutter test                   # Run tests
flutter analyze                # Static analysis
dart format lib test           # Format code
dart run build_runner build    # Code generation
```

### Directory Structure
- `lib/features/` - Feature modules (auth, home, journal, explore, calendar, profile, entry)
- `lib/core/` - Shared components, themes, utilities
- `lib/models/` - Data models
- `lib/repositories/` - Data access layer
- `lib/services/` - External service integrations

### Coding Conventions
- Commit format: `type(scope): description`
- Linter: `very_good_analysis`
- File naming: `snake_case.dart`
- Class naming: `PascalCase`

## Development Phases

| Phase | Status | Description |
|-------|--------|-------------|
| 1 | Pending | Core foundation (Auth, Entry CRUD, API integration) |
| 2 | Pending | Knowledge extraction (OCR, AI assistant) |
| 3 | Pending | Explore & recommendations (Explore, Calendar) |
| 4 | Pending | Platform expansion & release |

See `openspec/changes/` for detailed proposals per phase.

## Skills (Mandatory Rules for AI Assistants)

### Documentation Sync

When there are new features, changes, or important fixes, you **must** do all of the following:

1. **Update README.md** (English) — Add usage instructions and notes in the relevant section
2. **Update README.zh-TW.md** (Traditional Chinese) — Translate and add the same content
3. **Update CHANGELOG.md** — Add entries under `[Unreleased]` following [Keep a Changelog](https://keepachangelog.com/) format

#### CHANGELOG Format

```markdown
## [Unreleased]
### Added       — New features
### Changed     — Changes to existing features
### Deprecated  — Features to be removed in the future
### Removed     — Removed features
### Fixed       — Bug fixes
### Security    — Security patches
```

#### Notes
- Both READMEs must stay in sync (different languages, same information)
- CHANGELOG entries are written in English
- Entry format: `- <brief description> (#PR or commit ref)`
- On release, rename `[Unreleased]` to a version number and date: `## [x.y.z] - YYYY-MM-DD`

### Commit Rules

- Follow [Conventional Commits](https://www.conventionalcommits.org/) format: `type(scope): description`
- **Split commits by concern**: When there are many changed files, group them into separate commits based on what they change. Do NOT lump everything into a single commit. For example:
  - Config files → one commit
  - Docs/README changes → one commit
  - Feature code → one commit per feature or logical unit
  - Test files → one commit (or grouped with their feature)
- Each commit should be a single logical change that can be understood on its own
- When asked to commit, review all staged/unstaged changes first and propose a batching plan if multiple concerns are detected
