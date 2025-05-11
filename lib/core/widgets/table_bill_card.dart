import 'package:flutter/material.dart';
import 'package:rebill_flutter/core/models/bill.dart';

class TableBillCard extends StatelessWidget {
  const TableBillCard({super.key, required this.bill});

  final BillModel bill;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(bill.title ?? 'No title'),
          Text(bill.customerName),
          Text(bill.amountPaid.toString()),
        ],
      ),
    );
  }
}
