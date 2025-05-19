import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/features/stock-taking/providers/stock_taking_provider.dart';

class StockTakingDialog extends ConsumerStatefulWidget {
  const StockTakingDialog({super.key});

  @override
  ConsumerState<StockTakingDialog> createState() => _StockTakingDialogState();
}

class _StockTakingDialogState extends ConsumerState<StockTakingDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(stockTakingProvider.notifier).fetchStockTakings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final stockTaking = ref.watch(stockTakingProvider).stockTakings;
    return Expanded(
      child: ListView.builder(
        itemCount: stockTaking.length,
        itemBuilder: (context, index) {
          return Text(stockTaking[index].productName);
        },
      ),
    );
  }
}
