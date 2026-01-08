import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/category_provider.dart';
import '../providers/order_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_image.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  static const routeName = '/products';
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _query = '';
  String? _selectedCategoryId;
  bool _argsApplied = false;
  bool _grid = false;

  final Set<String> _categoryFilters = {}; // categoryId multi-select via sheet

  static const _sortNameAsc = 'Name (A–Z)';
  static const _sortCategoryAsc = 'Category';
  static const _sortNewest = 'Newest';
  String _sortMode = _sortNameAsc;

  void _addToOrder(BuildContext context, Product product) {
    context.read<OrderProvider>().add(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to order'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _checkout(BuildContext context) async {
    final orders = context.read<OrderProvider>();
    if (!orders.hasItems) return;
    await Navigator.of(context).pushNamed(CartScreen.routeName);
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ProductProvider>().load());
    _searchCtrl.addListener(() {
      setState(() {
        _query = _searchCtrl.text.trim().toLowerCase();
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsApplied) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      final catId = args['initialCategoryId'];
      if (catId is String && catId.isNotEmpty) {
        _selectedCategoryId = catId;
      }
    }
    _argsApplied = true;
  }


  void _openFilterSheet() {
    final cats = context.read<CategoryProvider>().categories;
    final categories = cats.toList()..sort((a, b) => a.name.compareTo(b.name));
    final tempCats = {..._categoryFilters};
    String tempSort = _sortMode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: StatefulBuilder(
            builder: (ctx, setModalState) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Filter & Sort', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 16),
                    const Text('Categories', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final c in categories)
                          FilterChip(
                            label: Text(c.name),
                            selected: tempCats.contains(c.id),
                            selectedColor: Theme.of(context).colorScheme.tertiary.withOpacity(0.18),
                            checkmarkColor: Theme.of(context).colorScheme.tertiary,
                            onSelected: (v) => setModalState(() {
                              v ? tempCats.add(c.id) : tempCats.remove(c.id);
                            }),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Sort by', style: TextStyle(fontWeight: FontWeight.w600)),
                    RadioListTile<String>(
                      value: _sortNameAsc,
                      groupValue: tempSort,
                      title: const Text(_sortNameAsc),
                      onChanged: (v) => setModalState(() => tempSort = v ?? _sortNameAsc),
                    ),
                    RadioListTile<String>(
                      value: _sortCategoryAsc,
                      groupValue: tempSort,
                      title: const Text(_sortCategoryAsc),
                      onChanged: (v) => setModalState(() => tempSort = v ?? _sortNameAsc),
                    ),
                    RadioListTile<String>(
                      value: _sortNewest,
                      groupValue: tempSort,
                      title: const Text(_sortNewest),
                      onChanged: (v) => setModalState(() => tempSort = v ?? _sortNameAsc),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setModalState(() {
                              tempCats.clear();
                              tempSort = _sortNameAsc;
                            }),
                            style: ButtonStyle(
                              foregroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.tertiary),
                              side: WidgetStateProperty.all(
                                BorderSide(color: Theme.of(context).colorScheme.tertiary.withOpacity(0.7)),
                              ),
                            ),
                            child: const Text('Reset'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              setState(() {
                                _categoryFilters
                                  ..clear()
                                  ..addAll(tempCats);
                                _sortMode = tempSort;
                              });
                              Navigator.of(ctx).pop();
                            },
                            child: const Text('Apply'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final orders = context.watch<OrderProvider>();
    final hasActiveFilters = _categoryFilters.isNotEmpty || _sortMode != _sortNameAsc;
    final categoriesProvider = context.watch<CategoryProvider>();
    final categories = categoriesProvider.categories;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            tooltip: 'Filter & Sort',
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.tune),
                if (hasActiveFilters)
                  const Positioned(
                    right: -1,
                    top: -1,
                    child: CircleAvatar(radius: 4, backgroundColor: Colors.redAccent),
                  ),
              ],
            ),
            onPressed: _openFilterSheet,
          ),
          IconButton(
            tooltip: _grid ? 'List view' : 'Grid view',
            icon: Icon(_grid ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _grid = !_grid),
          ),
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () {
              if (mounted) {
                _searchFocus.requestFocus();
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SearchBar(
              controller: _searchCtrl,
              focusNode: _searchFocus,
              leading: const Icon(Icons.search),
              hintText: 'Search products',
              trailing: [
                if (_searchCtrl.text.isNotEmpty)
                  IconButton(
                    tooltip: 'Clear',
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _searchCtrl.clear();
                      _searchFocus.requestFocus();
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: orders.hasItems
          ? FloatingActionButton.extended(
              onPressed: () => _checkout(context),
              icon: const Icon(Icons.shopping_cart_checkout),
              label: Text('Checkout (${orders.totalQuantity})'),
            )
          : null,
      body: Builder(
        builder: (_) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }
          final items = provider.products.where((p) {
            if (_query.isEmpty) return true;
            final n = p.name.toLowerCase();
            final c = p.category.name.toLowerCase();
            return n.contains(_query) || c.contains(_query);
          }).toList();

          Set<String>? effectiveCats;
          if (_categoryFilters.isNotEmpty) {
            effectiveCats = _categoryFilters;
          } else if (_selectedCategoryId != null) {
            effectiveCats = {_selectedCategoryId!};
          }

          final filtered = items.where((p) => effectiveCats == null || effectiveCats.contains(p.category.id)).toList();

          filtered.sort((a, b) {
            switch (_sortMode) {
              case _sortCategoryAsc:
                final c = a.category.name.compareTo(b.category.name);
                return c != 0 ? c : a.name.compareTo(b.name);
              case _sortNewest:
                return b.id.compareTo(a.id);
              case _sortNameAsc:
              default:
                return a.name.compareTo(b.name);
            }
          });
          if (filtered.isEmpty) {
            return const Center(child: Text('No products available'));
          }
          return Column(
            children: [
              SizedBox(
                height: 48,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final bool isAll = index == 0;
                    final cat = isAll ? null : categories[index - 1];
                    final selected = isAll ? _selectedCategoryId == null : cat!.id == _selectedCategoryId;
                    return ChoiceChip(
                      label: Text(isAll ? 'All' : cat!.name),
                      selected: selected,
                      selectedColor: Theme.of(context).colorScheme.tertiary.withOpacity(0.18),
                      checkmarkColor: Theme.of(context).colorScheme.tertiary,
                      onSelected: (_) => setState(() => _selectedCategoryId = isAll ? null : cat!.id),
                    );
                  },
                ),
              ),
              Expanded(
                child: _grid
                    ? GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 3 / 4,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final p = filtered[index];
                          final inCart = orders.contains(p);
                          return Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  ProductDetailScreen.routeName,
                                  arguments: ProductDetailArgs(product: p),
                                );
                              },
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
                                              topLeft: Radius.circular(12),
                                              topRight: Radius.circular(12),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          right: 6,
                                          top: 6,
                                          child: IconButton(
                                            visualDensity: VisualDensity.compact,
                                            style: ButtonStyle(
                                              backgroundColor: WidgetStateProperty.all(
                                                Theme.of(context).colorScheme.surface.withOpacity(0.85),
                                              ),
                                            ),
                                            icon: Icon(
                                              inCart ? Icons.check : Icons.add_shopping_cart_outlined,
                                              color: inCart ? Theme.of(context).colorScheme.primary : null,
                                            ),
                                            onPressed: () => _addToOrder(context, p),
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
                                        Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 4),
                                        Text(p.category.name, style: Theme.of(context).textTheme.bodySmall),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final p = filtered[index];
                          final inCart = orders.contains(p);
                          return ListTile(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            tileColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.25),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: AspectRatio(
                              aspectRatio: 1,
                              child: ProductImage(
                                assetName: p.imageUrl,
                                fallbackText: p.name,
                                category: p.category.name,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.category.name),
                                const SizedBox(height: 2),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: inCart ? 'Added' : 'Add to order',
                                  icon: Icon(inCart ? Icons.check : Icons.add_shopping_cart_outlined),
                                  onPressed: () => _addToOrder(context, p),
                                ),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                ProductDetailScreen.routeName,
                                arguments: ProductDetailArgs(product: p),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
