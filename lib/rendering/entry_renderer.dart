import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/app_settings.dart';
import '../models/dictionary_info.dart';
import '../core/dictionary_registry.dart';
import '../core/transliteration_service.dart';
import '../core/search_service.dart';
import '../core/ls_service.dart';
import '../core/logger.dart';
import 'entry_parser.dart';
import 'basic_adjust.dart';
import 'basic_display.dart';

/// Renders a [ParsedEntry] as a Flutter widget.
class EntryRenderer {
  final AppSettings settings;
  final String dictCode;
  final bool useCologneTheme;
  final Color? customAccentColor;
  final Color? customHeadwordColor;

  EntryRenderer(
      {required this.settings,
      required this.dictCode,
      this.useCologneTheme = false,
      this.customAccentColor,
      this.customHeadwordColor});

  /// Build the full entry widget including headword, body, and page ref.
  Future<Widget> buildEntryWidget({
    required ParsedEntry entry,
    required void Function(String slp1Word) onWordTap,
    required VoidCallback onCopy,
    required String dictCodeUp,
    required double lnum,
    String? highlightTerm,
  }) async {
    final dictInfo = DictionaryRegistry.byCode(dictCode)!;

    // 1. Pre-fetch abbreviations used in this entry
    final abbrsNeeded = EntryParser.extractAbbreviations(entry.bodyHtml);
    final abbrCache = <String, String>{};
    for (final abbr in abbrsNeeded) {
      final exp = await SearchService.fetchAbbreviation(
        dictCode: dictCode,
        abbr: abbr,
      );
      if (exp != null) abbrCache[abbr] = exp;
    }

    // 2. Pre-fetch LS (literary source) expansions using LsService
    final lsRefs = EntryParser.extractLsRefsWithDetails(entry.bodyHtml);
    debugPrint(
        '=== LS DEBUG: Dict=$dictCode, Extracted refs: ${lsRefs.length}');
    final lsCache = <String, String>{};
    final lsHrefs = <String, String>{};

    for (final ref in lsRefs) {
      debugPrint(
          '=== LS DEBUG: Processing n="${ref.nAttribute}", text="${ref.text}"');
      final result = await LsService.processLs(
        dictCode: dictCode,
        lsContent: ref.text,
        nAttribute: ref.nAttribute,
      );

      if (result != null) {
        final cacheKey = ref.nAttribute ?? ref.text;
        if (result.expansion != null) {
          lsCache[cacheKey] = result.expansion!;
          debugPrint('=== LS DEBUG: Stored in lsCache: key="$cacheKey"');
        }
        if (result.href != null) {
          lsHrefs[cacheKey] = result.href!;
          debugPrint(
              '=== LS DEBUG: Stored in lsHrefs: key="$cacheKey" => href="${result.href}"');
        } else {
          debugPrint('=== LS DEBUG: No href for key="$cacheKey"');
        }
      }
    }
    debugPrint('=== LS DEBUG: Final lsCache: $lsCache');
    debugPrint('=== LS DEBUG: Final lsHrefs: $lsHrefs');

    // DEBUG: Log raw entry HTML structure
    AppLogger.entry(dictCode, lnum, entry.key1Slp1, entry.bodyHtml);

    // 2. Build headword display string
    final slp1Key = _resolveHeadwordSlp1(entry);
    final displayKey = TransliterationService.fromSlp1(
        slp1Key, settings.outputTranslit,
        useAccented: settings.showAccent, dictCode: dictCode);

    // 3. Process body HTML
    final isEnglish = ['ae', 'mwe', 'bor'].contains(dictCode.toLowerCase());
    final highlightSlp1 = (highlightTerm != null && highlightTerm.isNotEmpty)
        ? (isEnglish
            ? highlightTerm.toLowerCase()
            : TransliterationService.toSlp1(
                highlightTerm, settings.inputTranslit))
        : null;

    final processedHtml = _buildBodyHtml(entry.bodyHtml, abbrCache, lsCache,
        lsHrefs, highlightSlp1, highlightTerm, dictCode);

    return _EntryCard(
      displayKey: displayKey,
      slp1Key: slp1Key,
      homonym: entry.homonym,
      processedHtml: processedHtml,
      pageCol: entry.pageCol,
      lnum: lnum,
      dictCodeUp: dictCodeUp,
      lsCache: lsCache,
      abbrCache: abbrCache,
      onWordTap: onWordTap,
      onCopy: onCopy,
      outputTranslit: settings.outputTranslit,
      dictInfo: dictInfo,
      useCologneTheme: useCologneTheme,
      customAccentColor: customAccentColor,
      customHeadwordColor: customHeadwordColor,
    );
  }

  String _resolveHeadwordSlp1(ParsedEntry entry) {
    if (settings.showAccent && entry.key2Slp1 != null) {
      return entry.key2Slp1!;
    }
    return entry.key1Slp1;
  }

  String _buildBodyHtml(
      String bodyHtml,
      Map<String, String> abbreviationCache,
      Map<String, String> lsCache,
      Map<String, String> lsHrefsParam,
      String? highlightSlp1,
      String? rawHighlightTerm,
      String dictCode) {
    // Apply BasicAdjust (Feature 5) if enabled
    String html = bodyHtml;
    if (settings.enableBasicAdjust) {
      html = BasicAdjust.adjust(
        xmlData: html,
        dictCode: dictCode,
        accent: settings.showAccent,
        outputTranslit: settings.outputTranslit,
      );
    }

    // Apply BasicDisplay (Feature 4) if enabled
    if (settings.enableBasicDisplay) {
      html = BasicDisplay.processHtml(
        html: html,
        dictCode: dictCode,
        outputTranslit: settings.outputTranslit,
        abbreviationCache: abbreviationCache,
        highlightTerm: rawHighlightTerm,
        highlightEnabled: settings.highlightEnabled,
        lsHrefs: lsHrefsParam, // parameter from _buildBodyHtml
      );
    }

    // Always apply transliteration (handles <s> and <SA> tags)
    // This is needed regardless of BasicDisplay toggle
    html = _applyTransliteration(html, abbreviationCache, lsCache, lsHrefsParam,
        highlightSlp1, rawHighlightTerm, dictCode);

    // Wrap in a div for styling
    return '<div style="font-size:15px; line-height:1.6;">$html</div>';
  }

  /// Apply transliteration to Sanskrit text within s and SA tags
  String _applyTransliteration(
      String html,
      Map<String, String> abbreviationCache,
      Map<String, String> lsCache,
      Map<String, String> lsHrefs,
      String? highlightSlp1,
      String? rawHighlightTerm,
      String dictCode) {
    html = html.replaceAllMapped(
      RegExp(r'<(?:s|SA)>(.*?)</(?:s|SA)>', dotAll: true),
      (m) {
        final slp1 = m.group(1) ?? '';

        String process(String text) {
          if (text.isEmpty) return '';
          return TransliterationService.fromSlp1(text, settings.outputTranslit,
              useAccented: settings.showAccent, dictCode: dictCode);
        }

        // Transliterate - <mark> tags are protected by TransliterationService
        final result = process(slp1);

        return '<span class="sanskrit">$result</span>';
      },
    );

    // Expand <ab>text</ab> abbreviations (if not already handled by BasicDisplay)
    // Also handle already-transformed <abbr title="...">text</abbr>
    // Add custom URL for tap-based tooltip via SnackBar
    html = html.replaceAllMapped(
      RegExp(r'<ab>(.*?)</ab>', dotAll: true),
      (m) {
        final abbr = m.group(1)?.trim() ?? '';
        final expansion = abbreviationCache[abbr];
        if (expansion != null) {
          final encoded = Uri.encodeComponent(expansion);
          return '<a href="sanslex://tooltip/ab/$encoded">$abbr</a>';
        }
        return abbr;
      },
    );
    // Handle already-transformed <abbr> elements (from BasicDisplay)
    html = html.replaceAllMapped(
      RegExp(r'<abbr\s+title="([^"]*)">(.*?)</abbr>', dotAll: true),
      (m) {
        final expansion = m.group(1)?.trim() ?? '';
        final abbr = m.group(2)?.trim() ?? '';
        if (expansion.isNotEmpty && abbr.isNotEmpty) {
          final encoded = Uri.encodeComponent(expansion);
          return '<a href="sanslex://tooltip/ab/$encoded">$abbr</a>';
        }
        return m.group(0) ?? '';
      },
    );

    // Style <ls> references (if not already handled by BasicDisplay)
    // Priority: external URL if available, otherwise tooltip via sanslex:// URL
    final lsHrefsMap = lsHrefs;
    html = html.replaceAllMapped(
      RegExp(r'<ls\s+n="([^"]*)">(.*?)</ls>', dotAll: true),
      (m) {
        final code = m.group(1) ?? '';
        final text = m.group(2) ?? '';
        final tooltip = lsCache[code] ?? code;
        final externalHref = lsHrefsMap[code];

        if (externalHref != null && externalHref.isNotEmpty) {
          return '<a href="$externalHref"><span class="ls" title="$tooltip">$text</span></a>';
        } else {
          final encoded = Uri.encodeComponent(tooltip);
          return '<a href="sanslex://tooltip/ls/$encoded" class="ls" title="$code">$text</a>';
        }
      },
    );
    html = html.replaceAllMapped(
      RegExp(r'<ls\s+n="([^"]*)"\s*/>'),
      (m) {
        final code = m.group(1) ?? '';
        final tooltip = lsCache[code] ?? code;
        final externalHref = lsHrefsMap[code];

        if (externalHref != null && externalHref.isNotEmpty) {
          return '<a href="$externalHref"><span class="ls" title="$tooltip">[$code]</span></a>';
        } else {
          final encoded = Uri.encodeComponent(tooltip);
          return '<a href="sanslex://tooltip/ls/$encoded" class="ls" title="$code">[$code]</a>';
        }
      },
    );
    // Handle already-transformed <span class="ls" title="..."> elements (from BasicDisplay)
    html = html.replaceAllMapped(
      RegExp(r'<span\s+class="ls"\s+title="([^"]*)">(.*?)</span>',
          dotAll: true),
      (m) {
        final code = m.group(1) ?? '';
        final text = m.group(2) ?? '';
        if (code.isNotEmpty && text.isNotEmpty) {
          final tooltip = lsCache[code] ?? code;
          final externalHref = lsHrefsMap[code];

          if (externalHref != null && externalHref.isNotEmpty) {
            return '<a href="$externalHref"><span class="ls" title="$tooltip">$text</span></a>';
          } else {
            final encoded = Uri.encodeComponent(tooltip);
            return '<a href="sanslex://tooltip/ls/$encoded" class="ls" title="$code">$text</a>';
          }
        }
        return m.group(0) ?? '';
      },
    );

    // Clean remaining custom tags that HtmlWidget won't know
    html = html.replaceAll(RegExp(r'</?F>'), '');
    html = html.replaceAll(RegExp(r'</?hom>'), '');
    html = html.replaceAll(RegExp(r'</?info[^>]*>'), '');
    html = html.replaceAll(RegExp(r'</?lex[^>]*>'), '');
    html = html.replaceAll(RegExp(r'</?s1[^>]*>'), '');

    // Apply highlighting to English/Non-Sanskrit matches
    if (rawHighlightTerm != null && rawHighlightTerm.isNotEmpty) {
      final escaped = RegExp.escape(rawHighlightTerm);
      html = html.replaceAllMapped(
        RegExp('(?<!<[^>]*)($escaped)(?![^<]*>)', caseSensitive: false),
        (match) => '<mark>${match.group(1)}</mark>',
      );
    }

    return html;
  }
}

/// Stateless widget that renders a single dictionary entry card.
class _EntryCard extends StatelessWidget {
  final String displayKey;
  final String slp1Key;
  final int? homonym;
  final String processedHtml;
  final String? pageCol;
  final double lnum;
  final String dictCodeUp;
  final Map<String, String> lsCache;
  final Map<String, String> abbrCache;
  final void Function(String slp1Word) onWordTap;
  final VoidCallback onCopy;
  final String outputTranslit;
  final DictionaryInfo dictInfo;
  final bool useCologneTheme;
  final Color? customAccentColor;
  final Color? customHeadwordColor;

  const _EntryCard({
    required this.displayKey,
    required this.slp1Key,
    this.homonym,
    required this.processedHtml,
    this.pageCol,
    required this.lnum,
    required this.dictCodeUp,
    required this.lsCache,
    required this.abbrCache,
    required this.onWordTap,
    required this.onCopy,
    required this.outputTranslit,
    required this.dictInfo,
    this.useCologneTheme = false,
    this.customAccentColor,
    this.customHeadwordColor,
  });

  Color _getHeadwordColor(ThemeData theme) {
    if (useCologneTheme) {
      return const Color(0xFF36648B); // Cologne blue
    }
    if (customHeadwordColor != null) {
      return customHeadwordColor!;
    }
    return theme.colorScheme.onSurface;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDevanagari = outputTranslit == 'devanagari';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Headword row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text: displayKey,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isDevanagari ? 18 : 16,
                        color: _getHeadwordColor(theme),
                      ),
                    ),
                    if (homonym != null)
                      TextSpan(
                        text: _superscript(homonym!),
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                  ]),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                tooltip: 'Copy entry',
                onPressed: onCopy,
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Definition body
          SelectionArea(
            child: HtmlWidget(
              processedHtml,
              textStyle: TextStyle(
                fontSize: isDevanagari ? 16 : 14,
                height: 1.6,
                color: theme.colorScheme.onSurface,
              ),
              onTapUrl: (url) async {
                if (url.startsWith('sanslex://lookup/')) {
                  final word = url.substring('sanslex://lookup/'.length);
                  onWordTap(word);
                  return true;
                }
                if (url.startsWith('sanslex://tooltip/')) {
                  // Parse tooltip URL: sanslex://tooltip/ab/{encoded} or sanslex://tooltip/ls/{encoded}
                  // URL structure: sanslex://tooltip/ab/encodedMessage
                  // Split gives: ['sanslex:', '', 'tooltip', 'ab', 'encodedMessage']
                  final parts = url.split('/');
                  debugPrint('=== TOOLTIP DEBUG: URL parts: $parts');
                  if (parts.length >= 5) {
                    final encoded = parts[4];
                    final message = Uri.decodeComponent(encoded);
                    // Clean HTML-encoded characters from tooltip text
                    final cleanedMessage = message
                        .replaceAll('&#13;', '')
                        .replaceAll('&#10;', '\n')
                        .replaceAll('&amp;', '&')
                        .replaceAll('&lt;', '<')
                        .replaceAll('&gt;', '>')
                        .replaceAll('&quot;', '"');
                    debugPrint(
                        '=== TOOLTIP DEBUG: Showing message: "$cleanedMessage"');
                    // Remove any existing SnackBar immediately and show new one
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(cleanedMessage),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  }
                  return true;
                }
                // Handle external http/https URLs - open in browser
                if (url.startsWith('http://') || url.startsWith('https://')) {
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                    return true;
                  }
                }
                return false;
              },
              customStylesBuilder: (element) {
                final isDark = theme.brightness == Brightness.dark;
                final primaryHex =
                    '#${theme.colorScheme.primary.toARGB32().toRadixString(16).substring(2).padLeft(6, '0')}';
                final secondaryContainerHex =
                    '#${theme.colorScheme.secondaryContainer.toARGB32().toRadixString(16).substring(2).padLeft(6, '0')}';
                final onSecondaryContainerHex =
                    '#${theme.colorScheme.onSecondaryContainer.toARGB32().toRadixString(16).substring(2).padLeft(6, '0')}';
                final primaryLightHex =
                    '${primaryHex.substring(0, 1)}0${primaryHex.substring(2)}';

                if (element.classes.contains('sanskrit')) {
                  // Subtle color for Sanskrit text
                  if (useCologneTheme) {
                    return {'color': '#339933'}; // Green for Cologne theme
                  }
                  if (customAccentColor != null) {
                    final hex =
                        '#${customAccentColor!.toARGB32().toRadixString(16).substring(2).padLeft(6, '0')}';
                    return {'color': hex}; // Custom accent color
                  }
                  return {
                    'color': isDark ? '#B0BEC5' : '#546E7A'
                  }; // Blue-grey variants
                }
                if (element.classes.contains('words')) {
                  // Headwords within definitions
                  if (useCologneTheme) {
                    return {'color': '#36648B'}; // Cologne blue for headwords
                  }
                  if (customHeadwordColor != null) {
                    final hex =
                        '#${customHeadwordColor!.toARGB32().toRadixString(16).substring(2).padLeft(6, '0')}';
                    return {'color': hex}; // Custom headword color
                  }
                  return {'color': primaryHex};
                }
                if (element.localName == 'b') {
                  return {'color': primaryHex};
                }
                // Style for tooltip links - dotted underline to indicate tappable
                if (element.localName == 'a' &&
                    element.attributes.containsKey('href') &&
                    element.attributes['href']!
                        .startsWith('sanslex://tooltip/')) {
                  return {
                    'color': isDark ? '#B0BEC5' : '#546E7A',
                    'text-decoration': 'underline dotted',
                  };
                }
                if (element.localName == 'abbr') {
                  return {
                    'color': 'inherit',
                    'text-decoration': 'underline dotted',
                  };
                }
                if (element.classes.contains('ls')) {
                  return {
                    'color': primaryLightHex,
                    'text-decoration': 'underline dotted',
                  };
                }
                if (element.localName == 'mark') {
                  return {
                    'background-color': secondaryContainerHex,
                    'color': onSecondaryContainerHex,
                  };
                }
                return null;
              },
            ),
          ),

          // Footer links
          const SizedBox(height: 6),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              _linkText(
                context,
                'PDF',
                dictInfo.pdfUrl(pageCol ?? ''),
              ),
              _linkText(
                context,
                'Correction',
                '${dictInfo.correctionBaseUrl}&lnum=${lnum.toStringAsFixed(0)}&hw=$slp1Key',
              ),
              if (pageCol != null)
                Text(
                  'page:${pageCol!}',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.outline,
                  ),
                ),
              Text(
                'ID:${lnum.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
          Divider(color: theme.colorScheme.outlineVariant),
        ],
      ),
    );
  }

  Widget _linkText(BuildContext context, String label, String url) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 13,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  String _superscript(int n) {
    const sup = ['⁰', '¹', '²', '³', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹'];
    return n.toString().split('').map((d) => sup[int.parse(d)]).join();
  }
}
