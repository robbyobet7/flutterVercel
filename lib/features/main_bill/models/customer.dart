class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String affiliate;
  final String joinDate;
  final String balance;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.affiliate,
    required this.joinDate,
    required this.balance,
  });

  // Convert JSON to Customer object
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      affiliate: json['affiliate'] as String,
      joinDate: json['joinDate'] as String,
      balance: json['balance'] as String,
    );
  }

  // Convert Customer object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'affiliate': affiliate,
      'joinDate': joinDate,
      'balance': balance,
    };
  }

  // Get a list of dummy customers
  static List<Customer> getDummyCustomers() {
    return [
      Customer(
        id: 'CUS001',
        name: 'John Smith',
        email: 'john.smith@example.com',
        phone: '+1 (555) 123-4567',
        affiliate: 'Gold',
        joinDate: '2023-01-15',
        balance: '1,250.00',
      ),
      Customer(
        id: 'CUS002',
        name: 'Mary Johnson',
        email: 'mary.j@example.com',
        phone: '+1 (555) 987-6543',
        affiliate: 'Silver',
        joinDate: '2023-02-20',
        balance: '780.50',
      ),
      Customer(
        id: 'CUS003',
        name: 'David Williams',
        email: 'dwilliams@example.com',
        phone: '+1 (555) 456-7890',
        affiliate: 'Bronze',
        joinDate: '2022-11-05',
        balance: '325.75',
      ),
      Customer(
        id: 'CUS004',
        name: 'Sarah Brown',
        email: 'sarah.b@example.com',
        phone: '+1 (555) 789-0123',
        affiliate: 'Premium',
        joinDate: '2023-03-30',
        balance: '2,100.25',
      ),
      Customer(
        id: 'CUS005',
        name: 'Michael Jones',
        email: 'mjones@example.com',
        phone: '+1 (555) 234-5678',
        affiliate: 'Standard',
        joinDate: '2022-12-10',
        balance: '940.00',
      ),
    ];
  }
}
