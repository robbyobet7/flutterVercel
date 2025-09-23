import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/providers/device_provider.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/app_divider.dart';
import 'package:rebill_flutter/core/widgets/app_search_bar.dart';
import 'package:rebill_flutter/core/widgets/list_header.dart';
import 'package:rebill_flutter/features/home/providers/search_provider.dart';
import 'package:rebill_flutter/features/stock-taking/models/stock_taking.dart';
import 'package:rebill_flutter/features/stock-taking/presentations/widgets/expandable_list.dart';
import 'package:rebill_flutter/features/stock-taking/presentations/widgets/type_filter_container.dart';
import 'package:rebill_flutter/features/stock-taking/providers/stock_taking_provider.dart';

class StockTakingDialog extends ConsumerStatefulWidget {
  const StockTakingDialog({super.key});

  @override
  ConsumerState<StockTakingDialog> createState() => _StockTakingDialogState();
}

class _StockTakingDialogState extends ConsumerState<StockTakingDialog> {
  // Track search text
  late final ScrollController _scrollController;
  late final TextEditingController _notesController;
  bool _isNotesVisible = false;
  late Future<void> _initStockFuture;

  // Structure to store stock changes (increment and checklist)
  final Map<int, int> _actualStockChanges = {}; // id -> increment value
  final Map<int, bool> _checkedItems = {}; // id -> checklist

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _notesController = TextEditingController();
    _initStockFuture = initializeStockTakings();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWeb = ref.watch(isWebProvider);
    final searchQuery = ref.watch(stockTakingSearchProvider);

    List<StockTaking> filterList(List<StockTaking> list) {
      if (searchQuery.isEmpty) return list;
      return list
          .where((item) => item.productName.toLowerCase().contains(searchQuery))
          .toList();
    }

    final headers = [
      Header(flex: 2, text: 'Item'),
      Header(flex: 1, text: 'Current Stock', textAlign: TextAlign.center),
      Header(flex: 1, text: 'Actual Stock', textAlign: TextAlign.center),
      Header(flex: 1, text: 'Checklist', textAlign: TextAlign.end),
    ];

    return Expanded(
      child: Column(
        children: [
          AppDivider(),

          SizedBox(height: 16),
          //filtering row
          SizedBox(
            height: 45,
            width: double.infinity,
            child: Row(
              children: [
                TypeFilterContainer(type: 'Products'),
                const SizedBox(width: 12),
                TypeFilterContainer(type: 'Ingredients'),
                const SizedBox(width: 12),
                TypeFilterContainer(type: 'Preps'),
                const SizedBox(width: 12),
                Expanded(
                  child: AppSearchBar(
                    key: const ValueKey('stock_taking_search'),
                    searchProvider: stockTakingSearchProvider,
                    onSearch: (value) {
                      ref
                          .read(stockTakingSearchProvider.notifier)
                          .updateSearchQuery(value);
                    },
                    onClear: () {
                      ref
                          .read(stockTakingSearchProvider.notifier)
                          .clearSearch();
                    },
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          //list header
          ListHeader(headers: headers),

          //Expandable list
          Expanded(
            child: FutureBuilder<void>(
              future: _initStockFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final ingredients = filterList(ref.watch(ingredientsProvider));
                final products = filterList(ref.watch(productStockProvider));
                final preps = filterList(ref.watch(prepsProvider));

                return ListView.builder(
                  controller: _scrollController,
                  physics: const ClampingScrollPhysics(),
                  cacheExtent: 1000, // Increased cache for smoother scrolling
                  addSemanticIndexes: false, // Performance optimization
                  itemCount: 3, // Fixed number of expandable lists
                  itemExtent:
                      products.isEmpty && ingredients.isEmpty && preps.isEmpty
                          ? 100 // Smaller height if all empty
                          : null, // Dynamic height based on content
                  itemBuilder: (context, index) {
                    // Each index represents one of our expandable lists
                    switch (index) {
                      case 0:
                        return isWeb
                            ? SizedBox(height: 12)
                            : Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: ExpandableList(
                                title: 'Products',
                                stockTakings: products,
                                onStockChanged: (id, value) {
                                  setState(() {
                                    _actualStockChanges[id] = value;
                                  });
                                },
                                onCheckChanged: (id, checked) {
                                  setState(() {
                                    _checkedItems[id] = checked;
                                  });
                                },
                              ),
                            );
                      case 1:
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: ExpandableList(
                            title: 'Ingredients',
                            stockTakings: ingredients,
                            onStockChanged: (id, value) {
                              setState(() {
                                _actualStockChanges[id] = value;
                              });
                            },
                            onCheckChanged: (id, checked) {
                              setState(() {
                                _checkedItems[id] = checked;
                              });
                            },
                          ),
                        );
                      case 2:
                        return Column(
                          children: [
                            ExpandableList(
                              title: 'Preps',
                              stockTakings: preps,
                              onStockChanged: (id, value) {
                                setState(() {
                                  _actualStockChanges[id] = value;
                                });
                              },
                              onCheckChanged: (id, checked) {
                                setState(() {
                                  _checkedItems[id] = checked;
                                });
                              },
                            ),
                          ],
                        );
                      default:
                        return SizedBox.shrink();
                    }
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          _isNotesVisible
              ? Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Add Notes',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    alignLabelWithHint: true,
                  ),
                ),
              )
              : const SizedBox.shrink(),

          SizedBox(
            height: 45,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppButton(
                  text: _isNotesVisible ? 'Hide Notes' : 'Add Notes',
                  onPressed: () {
                    setState(() {
                      _isNotesVisible = !_isNotesVisible;
                    });
                  },
                ),

                Row(
                  children: [
                    AppButton(
                      text: 'Cancel',
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      backgroundColor: theme.colorScheme.errorContainer,
                      textStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(width: 12),
                    AppButton(
                      text: 'Submit',
                      onPressed: () {
                        // Validation: if there is increment > 0 but checklist is not active, show failed dialog
                        bool hasInvalid = false;
                        _actualStockChanges.forEach((id, increment) {
                          if ((increment > 0) && (_checkedItems[id] != true)) {
                            hasInvalid = true;
                          }
                        });
                        if (hasInvalid) {
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: Text('Failed'),
                                  content: Text(
                                    'Please Activate the checklist before submit.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('OK'),
                                    ),
                                  ],
                                ),
                          );
                          return;
                        }
                        // Dummy submit process
                        setState(() {
                          // Take all ids that are checked
                          _checkedItems.forEach((id, checked) {
                            if (checked == true) {
                              final allStocks = [
                                ...ref.read(ingredientsProvider),
                                ...ref.read(productStockProvider),
                                ...ref.read(prepsProvider),
                              ];
                              StockTaking? stock;
                              try {
                                stock = allStocks.firstWhere((s) => s.id == id);
                              } catch (_) {
                                stock = null;
                              }
                              if (stock != null) {
                                final increment = _actualStockChanges[id] ?? 0;
                                if (increment > 0) {
                                  stock.productStock += increment;
                                }
                              }
                            }
                          });
                        });
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: Text('Success'),
                                content: Text(
                                  'Stock berhasil di-submit (dummy).',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('OK'),
                                  ),
                                ],
                              ),
                        );
                      },
                      backgroundColor: theme.colorScheme.primary,
                      textStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
