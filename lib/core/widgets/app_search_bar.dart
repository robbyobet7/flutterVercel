import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/providers/device_provider.dart';
import '../../features/home/providers/search_provider.dart';

class AppSearchBar extends ConsumerStatefulWidget {
  final String hintText;
  final Function(String)? onSearch;
  final Function()? onClear;
  final StateNotifierProvider<SearchNotifier, String>? searchProvider;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final double height;
  final EdgeInsetsGeometry padding;
  final Widget? searchIcon;
  final Widget? clearIcon;

  const AppSearchBar({
    super.key,
    this.hintText = 'Search...',
    this.onSearch,
    this.onClear,
    this.searchProvider,
    this.backgroundColor,
    this.borderRadius,
    this.height = 40,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
    this.searchIcon,
    this.clearIcon,
  });

  @override
  ConsumerState<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends ConsumerState<AppSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode(canRequestFocus: false);
  late StateNotifierProvider<SearchNotifier, String> _searchProvider;

  @override
  void initState() {
    super.initState();
    _searchProvider = widget.searchProvider ?? searchProvider;
    // Initialize controller with current search value
    _searchController.text = ref.read(_searchProvider);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = ref.watch(isWebProvider);
    final theme = Theme.of(context);
    // Watch search provider to keep UI in sync
    final searchQuery = ref.watch(_searchProvider);

    // Make sure controller text and provider state stay in sync
    if (_searchController.text != searchQuery) {
      _searchController.text = searchQuery;
      // Position cursor at the end
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchController.text.length),
      );
    }

    return GestureDetector(
      // Dismiss keyboard when tapping outside
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Container(
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? theme.colorScheme.surfaceContainer,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
        ),
        padding: widget.padding,
        width: double.infinity,
        height: widget.height,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                autofocus: false,
                onTapOutside: (value) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                decoration: InputDecoration(
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  hintText: widget.hintText,
                  border: InputBorder.none,
                  contentPadding:
                      isWeb
                          ? const EdgeInsets.symmetric(vertical: 17)
                          : const EdgeInsets.symmetric(vertical: 13),
                ),
                onChanged: (value) {
                  ref.read(_searchProvider.notifier).updateSearchQuery(value);
                  if (widget.onSearch != null) {
                    widget.onSearch!(value);
                  }
                },
                // Only handle focus events when explicitly tapped
                onTap: () {
                  // No automatic focus behavior
                },
                textAlignVertical: TextAlignVertical.center,
              ),
            ),
            Row(
              children: [
                if (searchQuery.isNotEmpty)
                  GestureDetector(
                    // Stop the parent gesture detector from receiving this tap
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      ref.read(_searchProvider.notifier).clearSearch();
                      // Also unfocus to hide keyboard
                      _searchFocusNode.unfocus();
                      if (widget.onClear != null) {
                        widget.onClear!();
                      }
                    },
                    child:
                        widget.clearIcon ??
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(Icons.clear, size: 20),
                        ),
                  ),
                GestureDetector(
                  // Stop the parent gesture detector from receiving this tap
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (_searchController.text.isNotEmpty) {
                      // Trigger search and dismiss keyboard
                      _searchFocusNode.unfocus();
                      if (widget.onSearch != null) {
                        widget.onSearch!(_searchController.text);
                      }
                    } else {
                      // Toggle focus behavior
                      if (_searchFocusNode.hasFocus) {
                        _searchFocusNode.unfocus();
                      } else {
                        _searchFocusNode.requestFocus();
                      }
                    }
                  },
                  child: widget.searchIcon ?? const Icon(Icons.search),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
