class UserBill {
  final String id;
  final String name;
  final String role;
  final int openBills;

  UserBill({
    required this.id,
    required this.name,
    required this.role,
    this.openBills = 0,
  });

  // Dummy data for dropdown
  static List<UserBill> dummyUsers = [
    UserBill(id: "1", name: "My Bills", role: "Current User", openBills: 5),
    UserBill(id: "2", name: "John Doe", role: "Waiter", openBills: 3),
    UserBill(id: "3", name: "Jane Smith", role: "Cashier", openBills: 8),
    UserBill(
      id: "4",
      name: "Robert Johnsonsssss",
      role: "Manager",
      openBills: 2,
    ),
    UserBill(id: "5", name: "All Bills", role: "Admin Access", openBills: 18),
  ];
}
