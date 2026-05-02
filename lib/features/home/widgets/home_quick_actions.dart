import 'package:flutter/material.dart';
import '../../dictionaries/manage_dictionaries_screen.dart';
import '../../preferences/preferences_screen.dart';
import '../../help/help_screen.dart';
import '../../about/about_us_screen.dart';

class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        // Subtle watermark-like search icon
        Icon(
          Icons.search,
          size: 100,
          color: Theme.of(context).colorScheme.primary.withAlpha(10),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(30),
              ],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildIconButton(
                context,
                icon: Icons.library_books,
                label: 'Dictionaries',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ManageDictionariesScreen()),
                ),
              ),
              _buildIconButton(
                context,
                icon: Icons.settings,
                label: 'Preferences',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PreferencesScreen()),
                ),
              ),
              _buildIconButton(
                context,
                icon: Icons.help_outline,
                label: 'Help',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpScreen()),
                ),
              ),
              _buildIconButton(
                context,
                icon: Icons.info_outline,
                label: 'About',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutUsScreen()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final color = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color.withAlpha(200), size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
