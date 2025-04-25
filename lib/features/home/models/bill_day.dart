class BillDay {
  final String date;
  final List<Bill> bills;

  BillDay({required this.date, required this.bills});

  // Dummy data for the bills table
  static final List<BillDay> dummyBillData = [
    BillDay(
      date: 'Today - July 15, 2023',
      bills: [
        Bill(name: 'Customer 1', total: '1112050', status: 'Closed'),
        Bill(name: 'Customer 2', total: '118575', status: 'Open'),
        Bill(name: 'Customer 3', total: '11210.00', status: 'Open'),
      ],
    ),
    BillDay(
      date: 'Yesterday - July 14, 2023',
      bills: [
        Bill(name: 'Customer 4', total: '115425', status: 'Closed'),
        Bill(name: 'Customer 5', total: '1118230', status: 'Closed'),
      ],
    ),
    BillDay(
      date: 'July 12, 2023',
      bills: [
        Bill(name: 'Customer 6', total: '119500', status: 'Open'),
        Bill(name: 'Customer 7', total: '116550', status: 'Open'),
        Bill(name: 'Customer 8', total: '1114575', status: 'Closed'),
      ],
    ),
  ];
}

class Bill {
  final String name;
  final String total;
  final String status;

  Bill({required this.name, required this.total, required this.status});
}
