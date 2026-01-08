import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/company.dart';

class ContactScreen extends StatelessWidget {
  static const routeName = '/contact';
  const ContactScreen({super.key});

  Future<void> _openEmail() async {
    final uri = Uri(scheme: 'mailto', path: Company.email);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openWhatsApp() async {
    final number = Company.whatsappNumber.replaceAll('+', '');
    final uri = Uri.parse('https://wa.me/$number');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openWebsite() async {
    final uri = Uri.parse(Company.website);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(Company.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.email_outlined),
              title: const Text('Email'),
              subtitle: Text(Company.email),
              onTap: _openEmail,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.chat_outlined),
              title: const Text('WhatsApp'),
              subtitle: Text(Company.whatsappNumber),
              onTap: _openWhatsApp,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.public),
              title: const Text('Website'),
              subtitle: Text(Company.website),
              onTap: _openWebsite,
            ),
          ],
        ),
      ),
    );
  }
}
