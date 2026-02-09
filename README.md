# Cultainer

A comprehensive cross-platform (iOS / macOS / Web) media consumption tracker and knowledge extraction tool.

**English** | [繁體中文](README.zh-TW.md)

## Features

- 📚 **Unified Management** - Track books, movies, TV shows, and music
- 📸 **OCR Extraction** - Capture and recognize text from books instantly
- 🤖 **AI Assistant** - Smart analysis and summaries powered by Gemini Pro
- 🔍 **Discovery** - Recommendations based on creators you've enjoyed
- 📅 **Timeline** - Calendar view to review your media journey
- ☁️ **Cloud Sync** - Firebase-powered cross-device synchronization

## Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase (Firestore, Auth, Storage)
- **AI**: Google ML Kit (OCR), Gemini Pro
- **External APIs**: Google Books, TMDB, Spotify

## Development Setup

### Prerequisites

- Flutter SDK >= 3.19
- Dart SDK >= 3.3
- VS Code + Flutter extension (primary development environment)
- Xcode (only for iOS/macOS simulator and release signing)
- Android Studio or Android SDK (Android emulator)
- Firebase CLI

> 💡 **Development Strategy**: Use VS Code for daily development. Xcode is only needed for App Store signing and submission.

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/your-username/cultainer.git
cd cultainer

# 2. Install dependencies
flutter pub get

# 3. Set up environment variables
cp .env.example .env
# Edit .env and fill in your API keys

# 4. Configure Firebase
flutterfire configure

# 5. Install pre-commit hooks
dart pub global activate lefthook
lefthook install

# 6. Run the app
flutter run
```

### Environment Variables

Create a `.env` file:

```env
TMDB_API_KEY=your_tmdb_api_key
SPOTIFY_CLIENT_ID=your_spotify_client_id
SPOTIFY_CLIENT_SECRET=your_spotify_client_secret
```

## Project Structure

```
lib/
├── main.dart              # Application entry point
├── app/                   # App configuration, routing
├── core/                  # Shared components, themes, utilities
├── features/              # Feature modules
│   ├── auth/              # Authentication
│   ├── home/              # Home page
│   ├── journal/           # Journal
│   ├── explore/           # Explore
│   ├── calendar/          # Calendar
│   ├── profile/           # Profile
│   └── entry/             # Entry management
├── models/                # Data models
├── repositories/          # Data access layer
└── services/              # External service integrations
```

## Development Commands

```bash
# Format code
dart format lib test

# Static analysis
flutter analyze

# Run tests
flutter test

# Generate code (freezed, json_serializable)
dart run build_runner build

# Build iOS
flutter build ios

# Build macOS
flutter build macos

# Build Web
flutter build web
```

## VS Code Shortcuts

### Launch & Debug

| Shortcut | Action |
|----------|--------|
| `F5` | Start Debug mode (select target device in sidebar) |
| `Ctrl+F5` | Start Release mode |
| `Shift+F5` | Stop execution |
| `Cmd+Shift+F5` | Restart |

### Common Tasks

Press `Cmd+Shift+P` → type `Tasks: Run Task` to execute:

| Task Name | Description |
|-----------|-------------|
| Flutter: Get Packages | Install dependencies (`flutter pub get`) |
| Flutter: Build Runner | Generate code (freezed, json_serializable) |
| Flutter: Build Runner (Watch) | Watch and generate code continuously |
| Flutter: Run Tests | Run tests |
| Flutter: Run Tests with Coverage | Run tests with coverage report |
| Flutter: Analyze | Static analysis |
| Flutter: Format | Format code |
| Flutter: Clean | Clean cache and reinstall dependencies |
| Flutter: Build iOS (Release) | Build iOS release version |
| Flutter: Build Web | Build web version |
| Pre-commit Check | Full check (format + analyze + test) |

### Debug Configurations

In the `Run and Debug` panel (`Cmd+Shift+D`):

| Configuration | Description |
|---------------|-------------|
| cultainer (debug) | Default Debug mode |
| cultainer (profile) | Profile mode (performance analysis) |
| cultainer (release) | Release mode |
| cultainer (iOS Simulator) | Run on iOS Simulator |
| cultainer (Chrome) | Run in Chrome browser |
| cultainer (macOS) | Run on macOS |

### Recommended Extensions

VS Code will prompt you to install recommended extensions when opening the project:

- **Dart** - Dart language support
- **Flutter** - Flutter development tools
- **Awesome Flutter Snippets** - Code snippets
- **Error Lens** - Inline error display
- **GitLens** - Git enhancement tools
- **Todo Tree** - TODO comment tracking

## Development Guidelines

- Follow [Conventional Commits](https://www.conventionalcommits.org/) format
- Use `very_good_analysis` linter
- Code must pass pre-commit hooks
- See [openspec/project.md](openspec/project.md) for details

## License

MIT License
