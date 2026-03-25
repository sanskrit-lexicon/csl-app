# Cologne Sanskrit Lexicon App

A Flutter-based offline dictionary application for the [Cologne Digital Sanskrit Dictionaries](https://www.sanskrit-lexicon.uni-koeln.de/).

## Features

### Search Capabilities
- **Headword Search**: Search for words as they appear in dictionaries
- **Definition Search**: Search within dictionary definitions and explanations
- **Search Modes**: Choose between Prefix (default), Exact, Suffix, or Substring matching
- **Real-time Results**: See results as you type

### Dictionary Management
- **Multiple Dictionaries**: Access multiple Sanskrit dictionaries
- **Download on Demand**: Download only the dictionaries you need
- **Priority Ordering**: Set the order in which dictionaries appear in results
- **Dictionary Tabs**: View results from different dictionaries in separate tabs

### Display Options
- **Transliteration Schemes**: Choose your preferred input and output transliteration (ITRANS, Harvard-Kyoto, SLP1, Devanagari, etc.)
- **Theme Options**: 
  - Cologne (light blue theme matching the Cologne website)
  - Light/Dark modes
  - Custom theme with personalized colors
- **Vedic Accents**: Toggle display of pitch accent marks when available

### User Experience
- **Offline Access**: All downloaded dictionaries work without internet
- **Copy to Clipboard**: Easily copy entries
- **PDF Links**: Jump to original source pages
- **Correction Links**: Report errors directly to dictionary maintainers

## Supported Dictionaries

The app supports all dictionaries from the Cologne Digital Sanskrit Lexicon.

## Theme Customization

#### Custom Theme Colors

When Custom theme is selected, you can customize:

| Color | Description |
|-------|-------------|
| **Primary Color** | App bar, buttons, links |
| **Background Color** | Main screen background |
| **Headword Color** | Words shown as headwords in definitions |
| **Sanskrit Text Color** | Sanskrit text within definitions |

Use the preset buttons to start with existing themes, then tweak the colors to your liking.


##### Available Presets
- **Cologne**: Light blue theme matching the Cologne website
- **Light**: Classic light theme
- **Dark**: Dark mode for low-light environments
- **Whitr**: Clean white theme with blue

## Search Modes Explained

| Mode | Description |
|------|-------------|
| **Prefix** (default) | Matches words starting with your query |
| **Exact** | Matches the exact word only |
| **Suffix** | Matches words ending with your query |
| **Substring** | Matches words containing your query anywhere |

## Transliteration Schemes

| Scheme | Example ( Sanskrit ) |
|--------|---------------------|
| ITRANS (default)| surya |
| Harvard-Kyoto | sUrya |
| SLP1 | sUrya |
| Devanagari | सूर्य |

## Architecture

The app follows a clean architecture pattern:

```
lib/
├── core/           # Core services and utilities
├── features/       # Feature modules
│   ├── about/      # About screen
│   ├── dictionaries/ # Dictionary management
│   ├── help/       # User manual
│   ├── home/       # Main search screen
│   └── preferences/ # Settings and preferences
├── models/         # Data models
├── providers/     # State management (Riverpod)
└── rendering/     # Entry rendering logic
```

## Technologies Used

### Core
- [Flutter](https://pub.dev/packages/flutter): UI framework
- [Riverpod](https://pub.dev/packages/flutter_riverpod): State management

### Database & Storage
- [sqflite](https://pub.dev/packages/sqflite): SQLite database for offline dictionary storage
- [sqflite_common_ffi](https://pub.dev/packages/sqflite_common_ffi): Cross-platform SQLite support (desktop)
- [shared_preferences](https://pub.dev/packages/shared_preferences): User settings persistence

### Transliteration & Text Processing
- [indic_transliteration_dart](https://pub.dev/packages/indic_transliteration_dart): Sanskrit transliteration between various schemes
- [intl](https://pub.dev/packages/intl): Internationalization and date/number formatting

### UI Components
- [flutter_widget_from_html_core](https://pub.dev/packages/flutter_widget_from_html_core): HTML rendering for dictionary entries
- [flex_color_picker](https://pub.dev/packages/flex_color_picker): Color picker for custom themes
- [flutter_markdown_plus](https://pub.dev/packages/flutter_markdown_plus): Markdown rendering for help content
- [cupertino_icons](https://pub.dev/packages/cupertino_icons): iOS-style icons

### Utilities
- [path_provider](https://pub.dev/packages/path_provider): Access to device file system paths
- [http](https://pub.dev/packages/http): HTTP client for downloading dictionaries
- [archive](https://pub.dev/packages/archive): ZIP archive handling for dictionary downloads
- [url_launcher](https://pub.dev/packages/url_launcher): Opening external links (PDF, correction URLs)
- [package_info_plus](https://pub.dev/packages/package_info_plus): App version information

### Development
- [flutter_lints](https://pub.dev/packages/flutter_lints): Code quality checks
- [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons): App icon generation

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

For bug reports and feature requests, please use the GitHub issue tracker.

## License

This project is licensed under the GNU General Public License v3.0.

## Acknowledgments

- [Cologne Digital Sanskrit Dictionaries](https://www.sanskrit-lexicon.uni-koeln.de/)
- All contributors to the Sanskrit Lexicon project

## Contact Us

- Email: drdhaval2785@gmail.com
- GitHub: [sanskrit-lexicon/csl-app](https://github.com/sanskrit-lexicon/csl-app)

## Developer Corner

### API Reference

- [Public API Reference](reference/public.md) - Public classes, functions, and methods for external use
- [Private API Reference](reference/private.md) - Private implementation details

### Installation from Source

This is a flutter project. The instruction presumes that you have flutter set up on your machine.

```bash
# Clone the repository
git clone https://github.com/sanskrit-lexicon/csl-app.git

# Navigate to project directory
cd csl-app

# Get dependencies
flutter pub get

# Run the app
flutter run
```

### Building for Production

```bash
# Build for Android
flutter build apk --release

# Build for iOS
flutter build ios --release

# Build for Desktop (Windows/Linux/macOS)
flutter build <platform> --release
```

