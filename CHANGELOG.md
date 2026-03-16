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
- Tags management page accessible from Profile settings
- Creator ID storage for media search results (Google Books authors, TMDB directors)
- Collections section on Home page showing entries grouped by media type
- Excerpt system with Firestore subcollection CRUD (ExcerptRepository, providers)
- Excerpt UI: list section on entry detail, detail page with inline editing, add page
- GeminiService for AI-powered excerpt analysis via REST API (gemini-2.0-flash)
- AI analysis feature in excerpt detail page with save capability
- Gemini API key configuration in Profile settings
- `http` package dependency for REST API services
- OCR text recognition via Google ML Kit (iOS only) with camera and gallery capture
- OcrCapturePage with image source selection, text editing, and excerpt save
- Summarize All button for excerpts (Gemini-powered multi-excerpt summary)
- Review enhancement with AI (Gemini-powered review polishing in entry detail)
- API key validation flow with real-time feedback in Gemini settings dialog
- AI feature usage instructions in Gemini API key dialog
- `google_mlkit_text_recognition` and `image_picker` dependencies
- SpotifyService for music search via Spotify Web API (client credentials flow)
- Spotify integration in MediaSearchService unified search
- Repository unit tests for Entry, Tag, and Excerpt (using fake_cloud_firestore)
- Core widget tests for AppButton, AppTextField, AppCard, AppChip
- SpotifyService unit tests
- `fake_cloud_firestore` dev dependency for Firestore mocking in tests
- Auth flow integration tests (AuthRepository, providers, router redirect logic)
- Privacy policy document (PRIVACY_POLICY.md)
- iOS Info.plist: camera and photo library permissions for OCR, encryption declaration
- Android AndroidManifest.xml: internet and camera permissions, proper app label
- Custom app icons for iOS, Android, macOS, and Web (generated via flutter_launcher_icons)
