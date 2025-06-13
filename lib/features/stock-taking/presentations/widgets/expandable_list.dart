import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/widgets/app_checkbox.dart';
import 'package:rebill_flutter/core/widgets/app_material.dart';
import 'package:rebill_flutter/core/widgets/app_text_field.dart';
import 'package:rebill_flutter/core/widgets/decrement_button.dart';
import 'package:rebill_flutter/core/widgets/header_column.dart';
import 'package:rebill_flutter/core/widgets/increment_button.dart';
import 'package:rebill_flutter/features/stock-taking/models/stock_taking.dart';

class ExpandableList extends ConsumerStatefulWidget {
  const ExpandableList({
    super.key,
    required this.stockTakings,
    required this.title,
  });

  final List<StockTaking> stockTakings;
  final String title;

  @override
  ConsumerState<ExpandableList> createState() => _ExpandableListState();
}

class _ExpandableListState extends ConsumerState<ExpandableList>
    with SingleTickerProviderStateMixin {
  // Use a map for better access patterns with large lists
  final Map<int, TextEditingController> _controllerCache = {};
  bool _isExpanded = true;
  late final AnimationController _controller;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scrollController = ScrollController();
  }

  // Get or create controller as needed
  TextEditingController _getController(int id) {
    if (!_controllerCache.containsKey(id)) {
      _controllerCache[id] = TextEditingController();
    }
    return _controllerCache[id]!;
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in _controllerCache.values) {
      controller.dispose();
    }
    _controllerCache.clear();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stockTakings = widget.stockTakings;
    final theme = Theme.of(context);

    if (_isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    return AnimatedSize(
      duration: Duration(milliseconds: 200),
      reverseDuration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      clipBehavior: Clip.hardEdge,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.primary),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            //header
            AppMaterial(
              borderRadius:
                  !_isExpanded
                      ? BorderRadius.circular(12)
                      : BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                  ),
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.title, style: theme.textTheme.displaySmall),
                      Row(
                        children: [
                          Text(
                            '${stockTakings.length} items',
                            style: theme.textTheme.labelMedium,
                          ),
                          SizedBox(width: 8),
                          Icon(
                            _isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: theme.colorScheme.onSurface,
                          ),
                          SizedBox(width: 12),
                          AppCheckbox(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            //list
            if (_isExpanded)
              LimitedBox(
                maxHeight: 200, // Prevent excessive height
                child:
                    stockTakings.isEmpty
                        ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No items available'),
                          ),
                        )
                        : Scrollbar(
                          controller: _scrollController,
                          thumbVisibility: true,
                          trackVisibility: true,
                          thickness: 6,
                          radius: Radius.circular(10),
                          child: ListView.builder(
                            controller: _scrollController,
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            itemCount: stockTakings.length,
                            itemExtent:
                                70.0, // Fixed height improves performance
                            cacheExtent:
                                500, // Increase cache for smoother scrolling
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            itemBuilder: (context, index) {
                              final item = stockTakings[index];
                              // Get or create controller for this item
                              final controller = _getController(item.id);

                              return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom:
                                        index != stockTakings.length - 1
                                            ? BorderSide(
                                              color:
                                                  theme
                                                      .colorScheme
                                                      .surfaceContainer,
                                            )
                                            : BorderSide.none,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CellColumn(flex: 2, text: item.productName),
                                    CellColumn(
                                      flex: 1,
                                      text: item.productStock.toString(),
                                      textAlign: TextAlign.center,
                                    ),
                                    CellColumn(
                                      flex: 1,
                                      text: '',
                                      child: SizedBox(
                                        height: 45,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          spacing: 12,
                                          children: [
                                            DecrementButton(
                                              onTap: () {
                                                final currentValue =
                                                    int.tryParse(
                                                      controller.text,
                                                    ) ??
                                                    0;
                                                if (currentValue > 0) {
                                                  controller.text =
                                                      (currentValue - 1)
                                                          .toString();
                                                }
                                              },
                                            ),
                                            Expanded(
                                              child: AppTextField(
                                                showLabel: false,
                                                controller: controller,
                                                keyboardType:
                                                    TextInputType.number,
                                              ),
                                            ),
                                            IncrementButton(
                                              onTap: () {
                                                final currentValue =
                                                    int.tryParse(
                                                      controller.text,
                                                    ) ??
                                                    0;
                                                controller.text =
                                                    (currentValue + 1)
                                                        .toString();
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    CellColumn(
                                      flex: 1,
                                      text: '',
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [AppCheckbox()],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
              ),
          ],
        ),
      ),
    );
  }
}
