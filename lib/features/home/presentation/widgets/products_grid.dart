// Ganti isi file ProductsGrid Anda dengan ini

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Pastikan Anda punya import ini
import 'package:rebill_flutter/core/models/product.dart';
import 'package:rebill_flutter/core/providers/orientation_provider.dart';
// GANTI provider lama dengan provider paginasi yang baru
import 'package:rebill_flutter/core/providers/product_provider.dart';
import 'package:rebill_flutter/features/home/presentation/widgets/product_card.dart';

// 1. Ubah menjadi ConsumerStatefulWidget
class ProductsGrid extends ConsumerStatefulWidget {
  const ProductsGrid({super.key});

  @override
  ConsumerState<ProductsGrid> createState() => _ProductsGridState();
}

class _ProductsGridState extends ConsumerState<ProductsGrid> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Cek jika posisi scroll mendekati akhir list
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      // 300px buffer
      // Panggil fetchMoreProducts dari provider paginasi
      ref.read(paginatedProductsProvider.notifier).fetchMoreProducts();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLandscape = ref.watch(orientationProvider);

    // 2. Ganti sumber data ke paginatedProductsProvider
    final productsState = ref.watch(paginatedProductsProvider);
    final products = productsState.products;

    // Tampilkan loading besar saat fetch awal
    if (productsState.isLoading) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }

    // Tampilkan pesan error jika terjadi
    if (productsState.error != null) {
      return Expanded(
        child: Center(child: Text("Error: ${productsState.error}")),
      );
    }

    // Tampilkan pesan jika tidak ada produk
    if (products.isEmpty) {
      return Expanded(
        child: Center(
          child: Text('No products found', style: theme.textTheme.bodyLarge),
        ),
      );
    }

    // Widget Expanded tetap diperlukan jika parent-nya adalah Row atau Column
    return Expanded(
      child: GridView.builder(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        cacheExtent: 500,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isLandscape ? 2 : 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: isLandscape ? 0.7 : 0.8,
        ),
        // item counts is for loading view
        itemCount: products.length + (productsState.isFetchingMore ? 1 : 0),
        itemBuilder: (context, index) {
          // logic for loading
          if (index >= products.length) {
            return const Center(child: CircularProgressIndicator());
          }

          final product = products[index];
          return _buildProductItem(context, product, theme);
        },
      ),
    );
  }

  // Helper method
  Widget _buildProductItem(
    BuildContext context,
    Product product,
    ThemeData theme,
  ) {
    // Saya ganti format harga Anda dengan Intl agar lebih standar dan aman
    final price = NumberFormat.decimalPattern(
      'id',
    ).format(product.productsPrice ?? 0);
    final stock =
        product.hasInfiniteStock ? '∞' : product.availableStock.toString();

    return ProductCard(price: price, stock: stock, product: product);
  }
}
