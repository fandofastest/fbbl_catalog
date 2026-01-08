import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/company.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../providers/theme_provider.dart';
import 'auth_screen.dart';
import 'cart_screen.dart';
import 'my_transactions_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _openCart(BuildContext context) async {
    final orders = context.read<OrderProvider>();
    if (!orders.hasItems) return;
    await Navigator.of(context).pushNamed(CartScreen.routeName);
  }

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
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              final isLoggedIn = auth.isAuthenticated;
              return Card(
                child: ListTile(
                  leading: Icon(isLoggedIn ? Icons.person : Icons.login),
                  title: Text(isLoggedIn ? (auth.user?.name ?? 'Account') : 'Log in / Register'),
                  subtitle: Text(isLoggedIn ? auth.user?.email ?? '' : 'Save contact details and view order history'),
                  trailing: isLoggedIn
                      ? TextButton(
                          onPressed: auth.loading
                              ? null
                              : () async {
                                  await auth.logout();
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(content: Text('Signed out successfully')));
                                },
                          child: const Text('Log out'),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: isLoggedIn
                      ? null
                      : () => Navigator.of(context).pushNamed(AuthScreen.routeName),
                ),
              );
            },
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('My transactions'),
              subtitle: const Text('View your order history and statuses'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).pushNamed(MyTransactionsScreen.routeName),
            ),
          ),
          const Divider(),
          Consumer<OrderProvider>(
            builder: (context, orders, _) => Card(
              child: ListTile(
                leading: const Icon(Icons.shopping_bag_outlined),
                title: const Text('Basket'),
                subtitle: Text(orders.hasItems ? '${orders.totalQuantity} item(s) ready' : 'No items added yet'),
                trailing: orders.hasItems
                    ? FilledButton(
                        onPressed: () => _openCart(context),
                        child: const Text('Checkout'),
                      )
                    : null,
              ),
            ),
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
