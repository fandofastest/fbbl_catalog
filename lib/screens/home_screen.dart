import 'package:flutter/material.dart';
import '../config/company.dart';
import 'product_list_screen.dart';
import 'contact_screen.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../providers/product_provider.dart';
import 'product_detail_screen.dart';
import '../widgets/product_image.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _quickLinksController = ScrollController();
  bool _showLeftFade = false;
  bool _showRightFade = false;
  @override
  void initState() {
    super.initState();
    // Auto-load products for Featured section on first visit
    final provider = context.read<ProductProvider>();
    if (provider.products.isEmpty && !provider.loading) {
      Future.microtask(provider.load);
    }
    _quickLinksController.addListener(_onQuickLinksScroll);
  }

  void _onQuickLinksScroll() {
    if (!_quickLinksController.hasClients) return;
    final o = _quickLinksController.offset;
    final max = _quickLinksController.position.maxScrollExtent;
    final left = o > 2;
    final right = (max - o) > 2;
    if (left != _showLeftFade || right != _showRightFade) {
      setState(() {
        _showLeftFade = left;
        _showRightFade = right;
      });
    }
  }

  @override
  void dispose() {
    _quickLinksController.removeListener(_onQuickLinksScroll);
    _quickLinksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Corners'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<ProductProvider>().load();
        },
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.15),   // red tint
                      theme.colorScheme.secondary.withOpacity(0.22), // yellow tint
                      theme.colorScheme.tertiary.withOpacity(0.18),  // green tint
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: theme.colorScheme.surface.withOpacity(0.85),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Company.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            Company.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer.withOpacity(0.85),
                              height: 1.25,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              const _StatPill(label: 'Offline catalog', icon: Icons.offline_bolt_outlined),
                              const _StatPill(label: 'UK B2B', icon: Icons.business_outlined),
                              Consumer<ProductProvider>(
                                builder: (context, p, _) => _StatPill(
                                  label: '${p.products.length} products',
                                  icon: Icons.inventory_2_outlined,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ProductListScreen()),
                      ),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(theme.colorScheme.primary),
                        foregroundColor: WidgetStateProperty.all(theme.colorScheme.onPrimary),
                      ),
                      icon: const Icon(Icons.storefront),
                      label: const Text('View Products'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ContactScreen()),
                      ),
                      style: ButtonStyle(
                        foregroundColor: WidgetStateProperty.all(theme.colorScheme.tertiary),
                        side: WidgetStateProperty.all(
                          BorderSide(color: theme.colorScheme.tertiary.withOpacity(0.7)),
                        ),
                      ),
                      icon: const Icon(Icons.contact_support_outlined),
                      label: const Text('Contact Us'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Highlights',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProductListScreen()),
                    ),
                    child: const Text('Browse'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 196,
                child: Consumer<ProductProvider>(
                  builder: (context, provider, _) {
                    final items = provider.products.take(10).toList();

                    if (items.isEmpty) {
                      return Center(
                        child: Text(
                          provider.loading ? 'Loading…' : 'No highlights yet',
                          style: const TextStyle(color: Colors.black54),
                        ),
                      );
                    }

                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final p = items[index];
                        return SizedBox(
                          width: 240,
                          child: Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => Navigator.pushNamed(
                                context,
                                ProductDetailScreen.routeName,
                                arguments: ProductDetailArgs(product: p),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: ProductImage(
                                            assetName: p.imageUrl,
                                            fallbackText: p.name,
                                            category: p.category.name,
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(16),
                                              topRight: Radius.circular(16),
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(p.category.name, style: theme.textTheme.bodySmall),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  // keep typography consistent via Theme in other sections
                  Text('Quick Links', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: Stack(
                  children: [
                    Consumer<CategoryProvider>(
                      builder: (context, provider, _) {
                        final categories = provider.categories;
                        return ListView.separated(
                          controller: _quickLinksController,
                          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: categories.isNotEmpty ? categories.length : 2,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            if (categories.isEmpty) {
                              final label = index == 0 ? 'Beverage' : 'Food';
                              return _QuickLink(label: label);
                            }
                            final c = categories[index];
                            return _QuickLink(label: c.name, categoryId: c.id);
                          },
                        );
                      },
                    ),
                    if (_showLeftFade)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IgnorePointer(
                          child: Container(
                            width: 16,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  theme.colorScheme.surface,
                                  theme.colorScheme.surface.withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (_showRightFade)
                      Align(
                        alignment: Alignment.centerRight,
                        child: IgnorePointer(
                          child: Container(
                            width: 16,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerRight,
                                end: Alignment.centerLeft,
                                colors: [
                                  theme.colorScheme.surface,
                                  theme.colorScheme.surface.withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Featured',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProductListScreen()),
                    ),
                    child: const Text('See all'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: Consumer<ProductProvider>(
                  builder: (context, provider, _) {
                    final items = provider.products.take(8).toList();
                    if (items.isEmpty) {
                      return Center(
                        child: Text(
                          provider.loading ? 'Loading…' : 'No featured items',
                          style: const TextStyle(color: Colors.black54),
                        ),
                      );
                    }
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final p = items[index];
                        return SizedBox(
                          width: 260,
                          child: Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => Navigator.pushNamed(
                                context,
                                ProductDetailScreen.routeName,
                                arguments: ProductDetailArgs(product: p),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ProductImage(
                                      assetName: p.imageUrl,
                                      fallbackText: p.name,
                                      category: p.category.name,
                                      fit: BoxFit.cover,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(p.category.name, style: theme.textTheme.bodySmall),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final IconData icon;
  const _StatPill({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(label, style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _QuickLink extends StatelessWidget {
  final String label;
  final String? categoryId;
  const _QuickLink({required this.label, this.categoryId});

  IconData _iconForLabel(String label) {
    switch (label.toLowerCase()) {
      case 'beverages':
        return Icons.local_cafe_outlined;
      case 'food':
        return Icons.restaurant_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  Color _toneForLabel(BuildContext context, String label) {
    final cs = Theme.of(context).colorScheme;
    switch (label.toLowerCase()) {
      case 'beverages':
        return cs.secondary; // yellow
      case 'food':
        return cs.primary; // red
      default:
        return cs.tertiary; // green
    }
  }

  @override
  Widget build(BuildContext context) {
    final tone = _toneForLabel(context, label);
    return SizedBox(
      width: 120,
      child: Card
        (
        elevation: 0,
        color: tone.withOpacity(0.18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ProductListScreen(),
                settings: RouteSettings(
                  arguments: categoryId != null ? {'initialCategoryId': categoryId} : null,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_iconForLabel(label), color: tone, size: 20),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
