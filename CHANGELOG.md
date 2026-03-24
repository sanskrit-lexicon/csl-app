# Changelog

All notable changes to this project will be documented in this file.

## [0.1.3] - 2026-03-24

### Added
- **Cologne Theme**: Your favourite colour theme from Colgne website.
- **Custom Themes**: Choose your colours. Make it your own.


## [0.1.2] - 2026-03-24

### Added
- **A button to download files**: In case the user does not have any dictionaries installed, a button placed on the home screen for guiding users

## [0.1.1] - 2026-03-19

### Added
- **Reorderable Dictionaries**: Drag-and-drop prioritization in 'Manage Dictionaries' to control search result order and tab priority.
- **Copyable Definitions**: Enabled text selection and copying within dictionary entries.
- **Vedic Accent Support**: Implemented `slp1_accented` support with manual Devanagari fallback and dictionary-specific overrides for PWG and PW to match printed style.
- **Improved Highlighting**: Search terms are now highlighted before transliteration, ensuring accurate visual matches in Devanagari and other scripts.
- **Portable Tests**: Added a portable SQLite test database and updated search tests to be environment-independent.

### Changed
- **Default Settings**: 
    - Input transliteration defaults to **ITRANS**.
    - Output transliteration defaults to **Devanagari**.
    - Search mode now defaults to **Prefix**.
    - **Vedic Accents** are enabled by default.
- **Reordering UI**: Optimized the drag-and-drop handle location to prioritize the left side and avoid accidental deletes.

## [0.1.0] - 2026-03-16

### Initial Release
- Basic offline dictionary functionality with support for multiple Cologne Digital Sanskrit Lexicons.
- Multi-scheme transliteration support.
- Headword and definition search capabilities.
