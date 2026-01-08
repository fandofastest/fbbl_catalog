import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import 'product_detail_screen.dart';
import '../widgets/product_image.dart';

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
  String _selectedCategory = 'All';
  bool _argsApplied = false;
  bool _grid = false;

  final Set<String> _tagFilters = {}; // 'new', 'best'
  final Set<String> _categoryFilters = {}; // multi-select via sheet

  static const _sortNameAsc = 'Name (A–Z)';
  static const _sortCategoryAsc = 'Category';
  static const _sortNewest = 'Newest';
  String _sortMode = _sortNameAsc;

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
      final cat = args['initialCategory'];
      if (cat is String && cat.isNotEmpty) {
        _selectedCategory = cat;
      }
    }
    _argsApplied = true;
  }

  Widget _buildBadges(BuildContext context, ProductDetailArgs args) {
    final tags = args.product.tags.map((e) => e.toLowerCase()).toSet();
    final theme = Theme.of(context);
    final List<Widget> chips = [];
    if (tags.contains('new')) {
      chips.add(_tagChip(theme.colorScheme.secondary, 'New'));
    }
    if (tags.contains('best')) {
      chips.add(_tagChip(theme.colorScheme.primary, 'Best'));
    }
    if (chips.isEmpty) return const SizedBox.shrink();
    return Wrap(spacing: 6, runSpacing: 4, children: chips);
  }

  Widget _tagChip(Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _openFilterSheet() {
    final provider = context.read<ProductProvider>();
    final categories = {
      for (final p in provider.products) p.category
    }.toList()
      ..sort();

    final tempTags = {..._tagFilters};
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
                    const Text('Tags', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, children: [
                      FilterChip(
                        label: const Text('New'),
                        selected: tempTags.contains('new'),
                        selectedColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                        checkmarkColor: Theme.of(context).colorScheme.secondary,
                        onSelected: (v) => setModalState(() {
                          v ? tempTags.add('new') : tempTags.remove('new');
                        }),
                      ),
                      FilterChip(
                        label: const Text('Best'),
                        selected: tempTags.contains('best'),
                        selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        checkmarkColor: Theme.of(context).colorScheme.primary,
                        onSelected: (v) => setModalState(() {
                          v ? tempTags.add('best') : tempTags.remove('best');
                        }),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    const Text('Categories', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final c in categories)
                          FilterChip(
                            label: Text(c),
                            selected: tempCats.contains(c),
                            selectedColor: Theme.of(context).colorScheme.tertiary.withOpacity(0.18),
                            checkmarkColor: Theme.of(context).colorScheme.tertiary,
                            onSelected: (v) => setModalState(() {
                              v ? tempCats.add(c) : tempCats.remove(c);
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
                              tempTags.clear();
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
                                _tagFilters
                                  ..clear()
                                  ..addAll(tempTags);
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
    final hasActiveFilters = _tagFilters.isNotEmpty || _categoryFilters.isNotEmpty || _sortMode != _sortNameAsc;
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
      body: Builder(
        builder: (_) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }
          final categories = ['All', ...{
            for (final p in provider.products) p.category
          }];
          if (!categories.contains(_selectedCategory)) {
            _selectedCategory = 'All';
          }

          final items = provider.products.where((p) {
            if (_query.isEmpty) return true;
            final n = p.name.toLowerCase();
            final c = p.category.toLowerCase();
            return n.contains(_query) || c.contains(_query);
          }).toList();
          final withTags = items.where((p) {
            if (_tagFilters.isEmpty) return true;
            final tags = p.tags.map((e) => e.toLowerCase()).toSet();
            return _tagFilters.any(tags.contains);
          }).toList();

          Set<String>? effectiveCats;
          if (_categoryFilters.isNotEmpty) {
            effectiveCats = _categoryFilters;
          } else if (_selectedCategory != 'All') {
            effectiveCats = {_selectedCategory};
          }

          final filtered = withTags.where((p) => effectiveCats == null || effectiveCats.contains(p.category)).toList();

          filtered.sort((a, b) {
            switch (_sortMode) {
              case _sortCategoryAsc:
                final c = a.category.compareTo(b.category);
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
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final selected = cat == _selectedCategory;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: selected,
                      selectedColor: Theme.of(context).colorScheme.tertiary.withOpacity(0.18),
                      checkmarkColor: Theme.of(context).colorScheme.tertiary,
                      onSelected: (_) => setState(() => _selectedCategory = cat),
                    );
                  },
                ),
              ),
              Expanded(
                child: _grid
                    ? GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 3 / 4,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final p = filtered[index];
                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                ProductDetailScreen.routeName,
                                arguments: ProductDetailArgs(product: p),
                              );
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ProductImage(
                                      assetName: p.image,
                                      fallbackText: p.name,
                                      category: p.category,
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
                                        Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 4),
                                        Text(p.category, style: Theme.of(context).textTheme.bodySmall),
                                        const SizedBox(height: 4),
                                        _buildBadges(context, ProductDetailArgs(product: p)),
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
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final p = filtered[index];
                          return ListTile(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            tileColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.25),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: AspectRatio(
                              aspectRatio: 1,
                              child: ProductImage(
                                assetName: p.image,
                                fallbackText: p.name,
                                category: p.category,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.category),
                                const SizedBox(height: 2),
                                _buildBadges(context, ProductDetailArgs(product: p)),
                              ],
                            ),
                            trailing: const Icon(Icons.chevron_right),
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
