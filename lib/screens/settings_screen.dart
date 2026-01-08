import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../config/company.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('App Name'),
            subtitle: Text('Food Corners'),
          ),
          const Divider(),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark Mode'),
            subtitle: Text(theme.isDark ? 'On' : 'Off'),
            value: theme.isDark,
            onChanged: (v) => theme.setDark(v),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.privacy_tip_outlined),
            title: Text('Privacy Policy'),
            subtitle: Text('No data is collected. Offline-only app.'),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.app_shortcut_outlined),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('About', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(Company.name, style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Text(Company.description),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ExpansionTile(
              leading: const Icon(Icons.article_outlined),
              title: const Text('Terms & Conditions'),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: const [
                Text(
                  'This app is an offline product catalog for informational purposes only. Prices are available on request via WhatsApp or email. All trademarks belong to their respective owners.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
