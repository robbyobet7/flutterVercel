import 'package:rebill_flutter/core/models/bill.dart';

class BillDetails {
  final DateTime reportDate;
  final List<BillModel> bills;
  final double totalSales;
  final double cashSales;
  final double cardSales;
  final int billCount;
  final double averageSale;
  final Map<String, double> paymentMethodBreakdown;
  final Map<String, int> paymentMethodCount;

  BillDetails({
    required this.reportDate,
    required this.bills,
    required this.totalSales,
    required this.cashSales,
    required this.cardSales,
    required this.billCount,
    required this.averageSale,
    required this.paymentMethodBreakdown,
    required this.paymentMethodCount,
  });

  // Factory constructor to create a BillDetails from a list of bills
  factory BillDetails.fromBills(List<BillModel> bills, {DateTime? date}) {
    final reportDate = date ?? DateTime.now();
    final closedBills = bills.where((bill) => bill.states == 'closed').toList();

    // Calculate total sales
    final totalSales = closedBills.fold<double>(
      0.0,
      (sum, bill) => sum + bill.finalTotal,
    );

    // Calculate sales by payment method
    final cashBills =
        closedBills.where((bill) => bill.paymentMethod == 'Cash').toList();
    final cardBills =
        closedBills
            .where(
              (bill) =>
                  bill.paymentMethod != null && bill.paymentMethod != 'Cash',
            )
            .toList();

    final cashSales = cashBills.fold<double>(
      0.0,
      (sum, bill) => sum + bill.finalTotal,
    );
    final cardSales = cardBills.fold<double>(
      0.0,
      (sum, bill) => sum + bill.finalTotal,
    );

    // Calculate average sale
    final averageSale =
        closedBills.isNotEmpty ? totalSales / closedBills.length : 0.0;

    // Group bills by payment method
    final paymentMethodBreakdown = <String, double>{};
    final paymentMethodCount = <String, int>{};

    for (var bill in closedBills) {
      final method = bill.paymentMethod ?? 'Unknown';
      final currentTotal = paymentMethodBreakdown[method] ?? 0.0;
      paymentMethodBreakdown[method] = currentTotal + bill.finalTotal;
      paymentMethodCount[method] = (paymentMethodCount[method] ?? 0) + 1;
    }

    return BillDetails(
      reportDate: reportDate,
      bills: closedBills,
      totalSales: totalSales,
      cashSales: cashSales,
      cardSales: cardSales,
      billCount: closedBills.length,
      averageSale: averageSale,
      paymentMethodBreakdown: paymentMethodBreakdown,
      paymentMethodCount: paymentMethodCount,
    );
  }

  // Get percentage of sales by payment method
  Map<String, double> get paymentMethodPercentages {
    final result = <String, double>{};
    if (totalSales == 0) return result;

    paymentMethodBreakdown.forEach((method, amount) {
      result[method] = (amount / totalSales) * 100.0;
    });

    return result;
  }

  // Get most popular payment method
  String get mostPopularPaymentMethod {
    if (paymentMethodCount.isEmpty) return 'None';

    String mostPopular = 'None';
    int highestCount = 0;

    paymentMethodCount.forEach((method, count) {
      if (count > highestCount) {
        highestCount = count;
        mostPopular = method;
      }
    });

    return mostPopular;
  }

  // Calculate daily, weekly, or monthly growth (when compared to a previous BillDetails)
  double calculateGrowth(BillDetails previous) {
    if (previous.totalSales == 0) return 0.0;
    return ((totalSales - previous.totalSales) / previous.totalSales) * 100.0;
  }
}
