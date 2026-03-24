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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cologne Digital Sanskrit Dictionaries',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Offline dictionary application for the Cologne Sanskrit Lexicon.',
            ),
            const SizedBox(height: 24),
            Text(
              'License: GNU GPL v3.0',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            const Text(
              'For bug reports, feature requests, or corrections in entries:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
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
              title: const Text('drdhaval2785@gmail.com'),
              onTap: () => _launchEmail(context),
            ),
          ],
        ),
      ),
    );
  }
}
