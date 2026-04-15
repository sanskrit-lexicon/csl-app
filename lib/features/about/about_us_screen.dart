import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'drdhaval2785@gmail.com',
      queryParameters: {'subject': 'Cologne Sanskrit Lexicon Feedback'},
    );
    try {
      if (!await launchUrl(emailUri)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open email client')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Us')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              'Cologne Sanskrit Lexicon',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const Text(
              'An offline dictionary application for accessing '
              'the Cologne Digital Sanskrit Dictionaries.'
              'This app gets its data from the latest '
              'bleeding edge version of Cologne Sanskrit Lexicon.',
            ),
            const SizedBox(height: 24),
            Text(
              'License: GNU GPL v3.0',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            const Text(
              'Feedback & Contributions',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Web Version'),
              subtitle: const Text('sanskrit-lexicon.uni-koeln.de'),
              onTap: () => launchUrl(
                Uri.parse('https://www.sanskrit-lexicon.uni-koeln.de'),
                mode: LaunchMode.externalApplication,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('GitHub Repository'),
              onTap: () => launchUrl(
                Uri.parse('https://github.com/sanskrit-lexicon/csl-app'),
                mode: LaunchMode.externalApplication,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Contact'),
              onTap: () => _launchEmail(context),
            ),
            const SizedBox(height: 24),
            const Text(
              'About the Data',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            const Text(
              'The data comes from the Cologne Digital Sanskrit Dictionaries project, '
              'initiated in 1994 by the Institute of Indology and Tamil Studies '
              'at Cologne University, Germany. The project provides 42 dictionaries '
              'covering Sanskrit to English, German, French, and Latin (1832-1993). '
              'The original texts are in the public domain. '
              'Digitization and markup were supported by the DFG-NEH Project (2010-2013).',
            ),
          ],
        ),
      ),
    );
  }
}
