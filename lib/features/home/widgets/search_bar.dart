import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/search_provider.dart';

class HomeSearchBar extends ConsumerStatefulWidget {
  const HomeSearchBar({super.key});

  @override
  ConsumerState<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends ConsumerState<HomeSearchBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controller with current search value
    _searchController.text = ref.read(searchProvider);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Watch search provider to keep UI in sync
    final searchQuery = ref.watch(searchProvider);

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
      // Avoid registering as a tap when the user is interacting with children
      behavior: HitTestBehavior.translucent,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        width: double.infinity,
        height: 40,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search Product...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (value) {
                  ref.read(searchProvider.notifier).updateSearchQuery(value);
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
                      ref.read(searchProvider.notifier).clearSearch();
                    },
                    child: const Padding(
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
                      FocusScope.of(context).unfocus();
                    }
                  },
                  child: const Icon(Icons.search),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
