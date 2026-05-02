# Changelog

All notable changes to this project will be documented in this file.

## [0.2.2] - 2026-05-02

### Added
- **Welcome Screen**: Added a new welcome/onboarding screen for better first-time user experience.
- **Footer Icons**: Enhanced entry cards with clear icons for PDF, Correction, and ID information in the footer.

### Fixed
- **L-id Decimal Display**: Corrected dictionary entry ID (L-number) display to show full decimal precision (e.g., `1034.026` instead of `1034`).
- **Sequential Result Ordering**: Search results are now consistently ordered by their numeric L-id (`lnum`), ensuring entries appear in their proper dictionary sequence.

## [0.2.1] - 2026-04-15

### Added
- **Literary Sources for PW, PWG, PWKVN**: Added dart implementation to provide literary source references for pw, pwg, and pwkvn dictionaries. See #28.
- **Clickable Page Links in Definitions**: Page links inside definitions are now clickable, allowing quick navigation. See #27.
- **About Us Page**: Updated About Us section with more information about the app. See #29.

### Fixed
- **SRS Tag Handling**: Fixed proper handling of SRS tags in definitions. See #26.
- **Line Breaks in BOR**: Resolved line breaks issue in BOR dictionary. See #25.
- **Line Breaks and Page Links in ABCH/ACPH/ACSJ**: Fixed line breaks and page links issues in ABCH, ACPH, and ACSJ dictionaries. See #24.

## [0.2.0] - 2026-04-10

### Added
- **Web App on Github Pages works on Google Chrome**: Earlier version tried to work with wasm and failed. Now it is made default to javascript. Works on Google Chrome. Also works on iOS, macOS and Android.

## [0.1.7] - 2026-04-09

### Added
- **Web App on Github Pages**: Launched Cologne Sanskrit Lexicon Web App on Github Pages with full pipeline based on Github.
- **Literary Souces of PWG**: Added literary source links to websites for PWG as per website.
- **Siddhanta1 Font**: Started to use Siddhanta1 font as per suggestion at #22.
- **Font Size Preference**: Added font size -/+ slider in settings.

### Fixed
- **Engish Dictionaries Headwords**: Fixed wrong transliteration of English dictionary headwords to Devanagari and other schemes. See #20.
- **UI updates**: Mainly visual changes. See #18, #21.



## [0.1.6] - 2026-03-25

### Added
- **Siddhanta Font**: Integrated Siddhanta font for consistent Devanagari rendering across all platforms, resolving font compatibility issues on iOS.
- **Auto-enable Dictionaries**: Downloaded dictionaries are now automatically enabled for use. Previously downloaded dictionaries are also auto-enabled on app restart.

## [0.1.5] - 2026-03-25

### Added
- **List Mode**: New accordion-style view for search results, allowing users to browse multiple entries with only headwords listed. They can click on the headword of their choice to see definition.

## [0.1.4] - 2026-03-25

### Added
- **Literary Sources Linking**: Provided links to literary sources where available. Providing tooltip where available.
- **Abbreviation Tooltip**: Provided abbreviation tooltip where available.
- **Case-Insensitive Definition Search**: Search in definition now matches regardless of case, for typo tolerance.
- **Transliteration with Highlighting**: Search terms in definitions are now properly transliterated to the user's preferred output script while preserving highlighting.
- **Reference Documentation**: Added public and private API reference documents.

### Fixed
- **Definition Search Transliteration**: Fixed issue where highlighted search terms in definitions were not transliterated when using Devanagari or other output scripts.


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
