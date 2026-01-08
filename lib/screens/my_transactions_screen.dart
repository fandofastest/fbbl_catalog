import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction.dart';
import '../providers/auth_provider.dart';
import '../services/transaction_service.dart';
import 'auth_screen.dart';

class MyTransactionsScreen extends StatefulWidget {
  static const routeName = '/my-transactions';
  const MyTransactionsScreen({super.key});

  @override
  State<MyTransactionsScreen> createState() => _MyTransactionsScreenState();
}

class _MyTransactionsScreenState extends State<MyTransactionsScreen> {
  late Future<List<UserTransaction>> _future;
  bool _cancelling = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Widget _cancelButton(BuildContext context, UserTransaction t, Color accent) {
    return OutlinedButton.icon(
      onPressed: _cancelling ? null : () => _cancel(t),
      icon: const Icon(Icons.cancel_outlined, size: 18),
      label: Text(_cancelling ? 'Cancelling…' : 'Cancel'),
      style: OutlinedButton.styleFrom(
        foregroundColor: accent,
        side: BorderSide(color: accent.withOpacity(0.55)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _showDetails(UserTransaction t) async {
    final total = '£${(t.total / 100).toStringAsFixed(2)}';
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Transaction details'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID: ${t.id}'),
                  const SizedBox(height: 6),
                  Text('Status: ${t.status}'),
                  const SizedBox(height: 6),
                  Text('Total: $total', style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  const Divider(),
                  for (final line in t.items)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              line.product.name,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text('x${line.qty}'),
                          const SizedBox(width: 12),
                          Text('£${(line.price / 100).toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  bool _canCancel(UserTransaction t) {
    final s = t.status.toLowerCase();
    return s == 'pending' || s == 'processing';
  }

  Color _statusColor(BuildContext context, String status) {
    final cs = Theme.of(context).colorScheme;
    switch (status.toLowerCase()) {
      case 'pending':
        return cs.secondary;
      case 'processing':
        return cs.tertiary;
      case 'shipped':
        return cs.primary;
      case 'done':
      case 'completed':
        return Colors.green;
      case 'cancelled':
      case 'canceled':
        return Colors.redAccent;
      default:
        return cs.outline;
    }
  }

  Widget _statusBadge(BuildContext context, String status) {
    final c = _statusColor(context, status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.withOpacity(0.35)),
      ),
      child: Text(
        status,
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: c),
      ),
    );
  }

  Future<void> _cancel(UserTransaction t) async {
    if (_cancelling) return;
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel transaction?'),
        content: const Text('Are you sure you want to cancel this transaction?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('No')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Yes, cancel')),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _cancelling = true);
    try {
      await TransactionService().cancelTransaction(token: token, id: t.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction cancelled')));
      setState(() {
        _future = _load();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  Future<List<UserTransaction>> _load() async {
    final auth = context.read<AuthProvider>();
    if (auth.token == null) {
      return [];
    }
    return TransactionService().fetchMyTransactions(token: auth.token!);
  }

  Future<void> _ensureLoggedIn() async {
    final auth = context.read<AuthProvider>();
    if (auth.token != null) return;
    await Navigator.of(context).pushNamed(AuthScreen.routeName);
    if (!mounted) return;
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My transactions'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              setState(() {
                _future = _load();
              });
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<UserTransaction>>(
        future: _future,
        builder: (context, snapshot) {
          if (auth.token == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Please sign in to view your transactions.'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _ensureLoggedIn,
                      child: const Text('Sign in'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final items = snapshot.data ?? const <UserTransaction>[];
          if (items.isEmpty) {
            return const Center(child: Text('No transactions yet'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _future = _load();
              });
              await _future;
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final t = items[index];
                final total = '£${(t.total / 100).toStringAsFixed(2)}';
                final canCancel = _canCancel(t);
                final accent = _statusColor(context, t.status);
                final shortId = t.id.substring(0, t.id.length > 6 ? 6 : t.id.length);

                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: accent.withOpacity(0.9), width: 5),
                      ),
                      color: accent.withOpacity(0.04),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.receipt_long_outlined, color: accent),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Transaction #$shortId', style: const TextStyle(fontWeight: FontWeight.w800)),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 8,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        _statusBadge(context, t.status),
                                        Text('Total: $total', style: const TextStyle(fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => _showDetails(t),
                                icon: const Icon(Icons.info_outline, size: 18),
                                label: const Text('Details'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              if (canCancel) _cancelButton(context, t, accent),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
