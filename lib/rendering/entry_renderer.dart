import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import '../models/app_settings.dart';
import '../core/transliteration_service.dart';
import '../core/search_service.dart';
import 'entry_parser.dart';

/// Renders a [ParsedEntry] as a Flutter widget.
class EntryRenderer {
  final AppSettings settings;
  final String dictCode;

  EntryRenderer({required this.settings, required this.dictCode});

  /// Build the full entry widget including headword, body, and page ref.
  Future<Widget> buildEntryWidget({
    required ParsedEntry entry,
    required void Function(String slp1Word) onWordTap,
    required VoidCallback onCopy,
    required String dictCodeUp,
    required double lnum,
  }) async {
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

    // 2. Build headword display string
    final slp1Key = _resolveHeadwordSlp1(entry);
    final displayKey =
        TransliterationService.fromSlp1(slp1Key, settings.outputTranslit);

    // 3. Process body HTML
    final processedHtml = _buildBodyHtml(entry.bodyHtml, abbrCache);

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
    );
  }

  String _resolveHeadwordSlp1(ParsedEntry entry) {
    if (settings.showAccent && entry.key2Slp1 != null) {
      // Strip SLP1 accent '/' markers before transliterating
      return TransliterationService.stripSLP1Accents(entry.key2Slp1!);
    }
    return entry.key1Slp1;
  }

  String _buildBodyHtml(
      String bodyHtml, Map<String, String> abbreviationCache) {
    // Replace <s> and <SA> Sanskrit inline text with transliterated output
    String html = bodyHtml;

    html = html.replaceAllMapped(
      RegExp(r'<(?:s|SA)>(.*?)</(?:s|SA)>', dotAll: true),
      (m) {
        final slp1 = m.group(1) ?? '';
        final out =
            TransliterationService.fromSlp1(slp1, settings.outputTranslit);
        return '<b>$out</b>';
      },
    );

    // Expand <ab>text</ab> abbreviations
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

    // Style <ls> references as small grey text
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

    // Wrap in a div for styling
    return '<div style="font-size:15px; line-height:1.6;">$html</div>';
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
  });

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
                        color: theme.colorScheme.onSurface,
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
          HtmlWidget(
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
              if (element.classes.contains('sa') ||
                  element.localName == 'b') {
                return {'color': '#E07800'};
              }
              if (element.classes.contains('ls')) {
                return {'color': '#888888', 'font-style': 'italic'};
              }
              if (element.localName == 'mark') {
                return {
                  'background-color': '#FFD700',
                  'color': '#000000',
                };
              }
              return null;
            },
          ),
          // Footer links
          const SizedBox(height: 6),
          Row(
            children: [
              _linkText(
                context,
                'PDF',
                'https://www.sanskrit-lexicon.uni-koeln.de/scans/${dictCodeUp}Scan/2020/MCS/${dictCodeUp.toLowerCase()}${lnum.toInt()}.pdf',
              ),
              const SizedBox(width: 16),
              _linkText(
                context,
                'Correction',
                'https://www.sanskrit-lexicon.uni-koeln.de/scans/csl-corrections/app/correction_form_response.php?dict=$dictCodeUp&L=${lnum.toInt()}',
              ),
              if (pageCol != null) ...[
                const Spacer(),
                Text(
                  pageCol!,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
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
        // URL launching handled by parent via url_launcher
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
