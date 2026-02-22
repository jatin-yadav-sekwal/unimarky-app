// Marketplace data models — mirrors web MarketplacePage.tsx types

class MarketplaceItem {
  final String id;
  final String title;
  final String description;
  final String price;
  final String category;
  final String condition;
  final bool isNegotiable;
  final String? imageUrl;
  final String createdAt;

  MarketplaceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.condition,
    this.isNegotiable = false,
    this.imageUrl,
    required this.createdAt,
  });

  factory MarketplaceItem.fromJson(Map<String, dynamic> json) => MarketplaceItem(
    id: json['id']?.toString() ?? '',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    price: json['price']?.toString() ?? '0',
    category: json['category'] ?? '',
    condition: json['condition'] ?? '',
    isNegotiable: json['isNegotiable'] == true,
    imageUrl: json['imageUrl'],
    createdAt: json['createdAt'] ?? '',
  );
}

class SellerInfo {
  final String id;
  final String fullName;
  final String? mobileNumber;
  final String? department;
  final bool isVerified;

  SellerInfo({required this.id, required this.fullName, this.mobileNumber, this.department, this.isVerified = false});

  factory SellerInfo.fromJson(Map<String, dynamic> json) => SellerInfo(
    id: json['id']?.toString() ?? '',
    fullName: json['fullName'] ?? '',
    mobileNumber: json['mobileNumber'],
    department: json['department'],
    isVerified: json['isVerified'] == true,
  );
}

class MarketplaceItemDetail extends MarketplaceItem {
  final String? manufacturedYear;
  final SellerInfo seller;

  MarketplaceItemDetail({
    required super.id, required super.title, required super.description,
    required super.price, required super.category, required super.condition,
    super.isNegotiable, super.imageUrl, required super.createdAt,
    this.manufacturedYear, required this.seller,
  });

  factory MarketplaceItemDetail.fromJson(Map<String, dynamic> json) => MarketplaceItemDetail(
    id: json['id']?.toString() ?? '',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    price: json['price']?.toString() ?? '0',
    category: json['category'] ?? '',
    condition: json['condition'] ?? '',
    isNegotiable: json['isNegotiable'] == true,
    imageUrl: json['imageUrl'],
    createdAt: json['createdAt'] ?? '',
    manufacturedYear: json['manufacturedYear'],
    seller: SellerInfo.fromJson(json['seller'] ?? {}),
  );
}

// ── Constants ──

const marketplaceCategories = [
  {'value': 'all', 'label': 'All Items'},
  {'value': 'textbooks', 'label': 'Textbooks'},
  {'value': 'electronics', 'label': 'Electronics'},
  {'value': 'dorm-decor', 'label': 'Dorm Decor'},
  {'value': 'clothing', 'label': 'Clothing'},
  {'value': 'transport', 'label': 'Transport'},
  {'value': 'fitness', 'label': 'Fitness'},
];

const conditionLabels = {
  'new': 'Brand New',
  'like-new': 'Like New',
  'great': 'Great Condition',
  'good': 'Good Condition',
  'fair': 'Fair Condition',
};

const conditionOptions = [
  {'value': 'new', 'label': 'Brand New'},
  {'value': 'like-new', 'label': 'Like New'},
  {'value': 'great', 'label': 'Great Condition'},
  {'value': 'good', 'label': 'Good Condition'},
  {'value': 'fair', 'label': 'Fair Condition'},
];
