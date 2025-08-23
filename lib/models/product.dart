class Product {
  final String id;
  final String brand;
  final String description;
  final String image;
  final int price;
  final bool hasFunding;

  Product({
    required this.id,
    required this.brand,
    required this.description,
    required this.image,
    required this.price,
    this.hasFunding = false,
  });
}

class PriceRange {
  final String id;
  final String label;
  bool isSelected; // final 제거하여 수정 가능하도록 변경

  PriceRange({
    required this.id,
    required this.label,
    this.isSelected = false,
  });
}
