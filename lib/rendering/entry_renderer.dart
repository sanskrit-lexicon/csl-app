import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/app_settings.dart';
import '../models/dictionary_info.dart';
import '../core/dictionary_registry.dart';
import '../core/transliteration_service.dart';
import '../core/search_service.dart';
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

    final processedHtml = _buildBodyHtml(
        entry.bodyHtml, abbrCache, highlightSlp1, highlightTerm, dictCode);

    return _EntryCard(
      displayKey: displayKey,
      homonym: entry.homonym,
      processedHtml: processedHtml,
      pageCol: entry.pageCol,
      lnum: lnum,
      dictCodeUp: dictCodeUp,
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

  String _buildBodyHtml(String bodyHtml, Map<String, String> abbreviationCache,
      String? highlightSlp1, String? rawHighlightTerm, String dictCode) {
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
      );
    }

    // Always apply transliteration (handles <s> and <SA> tags)
    // This is needed regardless of BasicDisplay toggle
    html = _applyTransliteration(
        html, abbreviationCache, highlightSlp1, rawHighlightTerm, dictCode);

    // Wrap in a div for styling
    return '<div style="font-size:15px; line-height:1.6;">$html</div>';
  }

  /// Apply transliteration to Sanskrit text within s and SA tags
  String _applyTransliteration(
      String html,
      Map<String, String> abbreviationCache,
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

        String result;
        if (highlightSlp1 != null && highlightSlp1.isNotEmpty) {
          final escaped = RegExp.escape(highlightSlp1);
          final matches =
              RegExp('($escaped)', caseSensitive: false).allMatches(slp1);
          if (matches.isEmpty) {
            result = process(slp1);
          } else {
            final sb = StringBuffer();
            int lastEnd = 0;
            for (final match in matches) {
              sb.write(process(slp1.substring(lastEnd, match.start)));
              sb.write('<mark>${process(match.group(1)!)}</mark>');
              lastEnd = match.end;
            }
            sb.write(process(slp1.substring(lastEnd)));
            result = sb.toString();
          }
        } else {
          result = process(slp1);
        }

        return '<span class="sanskrit">$result</span>';
      },
    );

    // Expand <ab>text</ab> abbreviations (if not already handled by BasicDisplay)
    html = html.replaceAllMapped(
      RegExp(r'<ab>(.*?)</ab>', dotAll: true),
      (m) {
        final abbr = m.group(1)?.trim() ?? '';
        final expansion = abbreviationCache[abbr];
        if (expansion != null) {
          return '<abbr title="$expansion"><i>$abbr</i></abbr>';
        }
        return '<i>$abbr</i>';
      },
    );

    // Style <ls> references (if not already handled by BasicDisplay)
    html = html.replaceAllMapped(
      RegExp(r'<ls\s+n="([^"]*)">(.*?)</ls>', dotAll: true),
      (m) => '<small><i>${m.group(2)}</i></small>',
    );
    html = html.replaceAllMapped(
      RegExp(r'<ls\s+n="([^"]*)"\s*/>'),
      (m) => '<small><i>[${m.group(1)}]</i></small>',
    );

    // Clean remaining custom tags that HtmlWidget won't know
    html = html.replaceAll(RegExp(r'</?F>'), '');
    html = html.replaceAll(RegExp(r'</?hom>'), '');

    // Apply highlighting to English/Non-Sanskrit matches
    if (rawHighlightTerm != null && rawHighlightTerm.isNotEmpty) {
      final escaped = RegExp.escape(rawHighlightTerm);
      html = html.replaceAllMapped(
        RegExp('(?<!<[^>]*)\\b($escaped)\\b(?![^<]*>)', caseSensitive: false),
        (match) => '<mark>${match.group(1)}</mark>',
      );
    }

    return html;
  }
}

/// Stateless widget that renders a single dictionary entry card.
class _EntryCard extends StatelessWidget {
  final String displayKey;
  final int? homonym;
  final String processedHtml;
  final String? pageCol;
  final double lnum;
  final String dictCodeUp;
  final void Function(String slp1Word) onWordTap;
  final VoidCallback onCopy;
  final String outputTranslit;
  final DictionaryInfo dictInfo;
  final bool useCologneTheme;
  final Color? customAccentColor;
  final Color? customHeadwordColor;

  const _EntryCard({
    required this.displayKey,
    this.homonym,
    required this.processedHtml,
    this.pageCol,
    required this.lnum,
    required this.dictCodeUp,
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
              onTapUrl: (url) {
                if (url.startsWith('sanslex://lookup/')) {
                  final word = url.substring('sanslex://lookup/'.length);
                  onWordTap(word);
                  return true;
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
                final outlineHex =
                    '#${theme.colorScheme.outline.toARGB32().toRadixString(16).substring(2).padLeft(6, '0')}';

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
                if (element.classes.contains('ls')) {
                  return {'color': outlineHex, 'font-style': 'italic'};
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
          Row(
            children: [
              _linkText(
                context,
                'PDF',
                dictInfo.pdfUrl(pageCol ?? ''),
              ),
              const SizedBox(width: 16),
              _linkText(
                context,
                'Correction',
                dictInfo.correctionBaseUrl,
              ),
              const Spacer(),
              if (pageCol != null) ...[
                Text(
                  pageCol!,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                'ID=${lnum.toStringAsFixed(0)}',
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
