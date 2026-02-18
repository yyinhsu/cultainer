# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- Flutter project structure with core architecture (app, core, features, models)
- Dark theme design system based on mobile.pen specs (AppTheme, AppColors, AppTypography)
- Core UI component library (BottomNavBar, AppCard, AppButton, AppTextField, AppChip)
- Page scaffolds for Home, Explore, Journal, and Profile
- Data models with Firestore serialization (Entry, UserProfile, Tag, Excerpt)
- App routing with go_router and bottom navigation shell
- Mobile UI designs for Home, Calendar, Explore, Journal, and Profile pages (031e470)
- Project specs and OpenSpec phase 1-4 proposals (8b7867b)
- VS Code workspace configuration with launch, tasks, and recommended extensions (8b7867b)
- Lefthook pre-commit hooks configuration (8b7867b)
- Environment variables template `.env.example` (8b7867b)
- README in English and Traditional Chinese (8b7867b)
- Tags management page with full CRUD (create, edit, delete tags with color picker)
- "Manage Tags" shortcut in Profile settings
- Collections section on Home page showing entry counts by media type (Books, Movies, TV, Music)
- Comprehensive unit test suite: model tests (Entry, Tag, Excerpt, UserProfile)
- Service unit tests for GoogleBooksService and TmdbService using mock HTTP client
- Repository unit tests for EntryRepository and TagRepository using FakeFirebaseFirestore
- Core widget tests for AppButton, AppCard, AppChip, AppFilterChip, AppTagChip
- `fake_cloud_firestore` dev dependency for Firestore repository testing
