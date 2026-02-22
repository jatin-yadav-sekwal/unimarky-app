class Accommodation {
  final String id;
  final String name;
  final String type;
  final String location;
  final String? description;
  final String? address;
  final String? phone;
  final String? amenities;
  final String? rentRange;
  final String? contact;
  final double? minPrice;
  final double? maxPrice;
  final double rating;
  final int reviewCount;
  final List<String> images;

  Accommodation({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    this.description,
    this.address,
    this.phone,
    this.amenities,
    this.rentRange,
    this.contact,
    this.minPrice,
    this.maxPrice,
    this.rating = 0,
    this.reviewCount = 0,
    this.images = const [],
  });

  factory Accommodation.fromJson(Map<String, dynamic> json) {
    List<String> imgs = [];
    final raw = json['images'];
    if (raw is List) {
      imgs = raw.map((e) => e.toString()).toList();
    } else if (raw is String && raw.isNotEmpty) {
      try {
        final parsed = List<String>.from(
          (raw.startsWith('[')) ? _parseJsonList(raw) : [raw],
        );
        imgs = parsed;
      } catch (_) {
        imgs = [];
      }
    }

    return Accommodation(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String? ?? 'PG',
      location: json['location'] as String? ?? '',
      description: json['description'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      amenities: json['amenities'] as String?,
      rentRange: json['rentRange'] ?? json['rent_range'] as String?,
      contact: json['contact'] as String?,
      minPrice: double.tryParse('${json['minPrice'] ?? json['min_price'] ?? ''}'),
      maxPrice: double.tryParse('${json['maxPrice'] ?? json['max_price'] ?? ''}'),
      rating: double.tryParse('${json['rating'] ?? 0}') ?? 0,
      reviewCount: json['reviewCount'] ?? json['review_count'] ?? 0,
      images: imgs,
    );
  }

  List<String> get amenitiesList =>
      amenities?.split(',').map((a) => a.trim()).where((a) => a.isNotEmpty).toList() ?? [];

  String get priceDisplay {
    if (rentRange != null && rentRange!.isNotEmpty) return rentRange!;
    if (minPrice != null && maxPrice != null) return '₹${minPrice!.toInt()} - ₹${maxPrice!.toInt()}';
    if (minPrice != null) return 'From ₹${minPrice!.toInt()}';
    return 'Contact for price';
  }

  static List<dynamic> _parseJsonList(String raw) {
    // Simple JSON array parse
    return raw.replaceAll('[', '').replaceAll(']', '').replaceAll('"', '').split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }
}

const accommodationTypes = ['All', 'PG', 'Hostel', 'Apartment'];
