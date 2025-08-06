class StaffAccount {
  final int id;
  final String name;
  final List<Staff> staff;

  StaffAccount({required this.id, required this.name, required this.staff});

  factory StaffAccount.fromJson(Map<String, dynamic> json) {
    return StaffAccount(
      id: json['id'],
      name: json['name'],
      staff:
          (json['staff'] as List)
              .map((staffJson) => Staff.fromJson(staffJson))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'staff': staff.map((s) => s.toJson()).toList(),
    };
  }
}

class Staff {
  final int id;
  final String name;
  final int outletId;

  Staff({required this.id, required this.name, required this.outletId});

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'],
      name: json['name'],
      outletId: json['outlet_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'outlet_id': outletId};
  }
}
