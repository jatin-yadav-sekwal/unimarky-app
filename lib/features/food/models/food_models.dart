class Restaurant {
  final String id;
  final String name;
  final String location;
  final String? description;
  final String? cuisine;
  final String? tags;
  final String? address;
  final String? phone;
  final String? timing;
  final String? priceRange;
  final String? imageUrl;
  final double rating;
  final int reviewCount;

  Restaurant({
    required this.id,
    required this.name,
    required this.location,
    this.description,
    this.cuisine,
    this.tags,
    this.address,
    this.phone,
    this.timing,
    this.priceRange,
    this.imageUrl,
    this.rating = 0,
    this.reviewCount = 0,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
    id: json['id'] as String,
    name: json['name'] as String,
    location: json['location'] as String? ?? '',
    description: json['description'] as String?,
    cuisine: json['cuisine'] as String?,
    tags: json['tags'] as String?,
    address: json['address'] as String?,
    phone: json['phone'] as String?,
    timing: json['timing'] as String?,
    priceRange: json['priceRange'] ?? json['price_range'] as String?,
    imageUrl: json['imageUrl'] ?? json['image_url'] as String?,
    rating: double.tryParse('${json['rating'] ?? 0}') ?? 0,
    reviewCount: json['reviewCount'] ?? json['review_count'] ?? 0,
  );

  List<String> get tagList => tags?.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList() ?? [];
}

class MenuItem {
  final String id;
  final String name;
  final String restaurantId;
  final String? description;
  final String? category;
  final String? imageUrl;
  final double price;
  final double rating;
  final int reviewCount;
  final bool isVeg;
  final bool isAvailable;

  MenuItem({
    required this.id,
    required this.name,
    required this.restaurantId,
    this.description,
    this.category,
    this.imageUrl,
    required this.price,
    this.rating = 0,
    this.reviewCount = 0,
    this.isVeg = true,
    this.isAvailable = true,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
    id: json['id'] as String,
    name: json['name'] as String,
    restaurantId: json['restaurantId'] ?? json['restaurant_id'] ?? '',
    description: json['description'] as String?,
    category: json['category'] as String?,
    imageUrl: json['imageUrl'] ?? json['image_url'] as String?,
    price: double.tryParse('${json['price'] ?? 0}') ?? 0,
    rating: double.tryParse('${json['rating'] ?? 0}') ?? 0,
    reviewCount: json['reviewCount'] ?? json['review_count'] ?? 0,
    isVeg: json['isVeg'] ?? json['is_veg'] ?? true,
    isAvailable: json['isAvailable'] ?? json['is_available'] ?? true,
  );
}
