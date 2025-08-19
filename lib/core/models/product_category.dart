class ProductCategory {
  final int id;
  final int ownerId;
  final String categoriesName;
  final String billPrinter; // Ini string '1' atau '0', bukan boolean
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  ProductCategory({
    required this.id,
    required this.ownerId,
    required this.categoriesName,
    required this.billPrinter,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  // Getter untuk kemudahan di UI
  bool get isBillPrinted => billPrinter == '1';

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'],
      ownerId: json['owner_id'],
      categoriesName: json['categories_name'],
      billPrinter: json['bill_printer'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt:
          json['deleted_at'] != null
              ? DateTime.parse(json['deleted_at'])
              : null,
    );
  }
}
