// Lost & Found data models — mirrors web LostFoundPage.tsx types

class LostFoundItem {
  final String id;
  final String itemName;
  final String description;
  final String type; // "lost" | "found"
  final String? location;
  final String? imageUrl;
  final String status;
  final String createdAt;
  final String? reporterName;

  LostFoundItem({
    required this.id, required this.itemName, required this.description,
    required this.type, this.location, this.imageUrl,
    this.status = 'active', required this.createdAt, this.reporterName,
  });

  factory LostFoundItem.fromJson(Map<String, dynamic> json) => LostFoundItem(
    id: json['id']?.toString() ?? '',
    itemName: json['itemName'] ?? '',
    description: json['description'] ?? '',
    type: json['type'] ?? 'lost',
    location: json['location'],
    imageUrl: json['imageUrl'],
    status: json['status'] ?? 'active',
    createdAt: json['createdAt'] ?? '',
    reporterName: json['reporterName'],
  );
}

class ReporterInfo {
  final String id;
  final String fullName;
  final String? mobileNumber;
  final String? department;

  ReporterInfo({required this.id, required this.fullName, this.mobileNumber, this.department});

  factory ReporterInfo.fromJson(Map<String, dynamic> json) => ReporterInfo(
    id: json['id']?.toString() ?? '',
    fullName: json['fullName'] ?? '',
    mobileNumber: json['mobileNumber'],
    department: json['department'],
  );
}

class LostFoundItemDetail extends LostFoundItem {
  final ReporterInfo reporter;

  LostFoundItemDetail({
    required super.id, required super.itemName, required super.description,
    required super.type, super.location, super.imageUrl,
    super.status, required super.createdAt, super.reporterName,
    required this.reporter,
  });

  factory LostFoundItemDetail.fromJson(Map<String, dynamic> json) => LostFoundItemDetail(
    id: json['id']?.toString() ?? '',
    itemName: json['itemName'] ?? '',
    description: json['description'] ?? '',
    type: json['type'] ?? 'lost',
    location: json['location'],
    imageUrl: json['imageUrl'],
    status: json['status'] ?? 'active',
    createdAt: json['createdAt'] ?? '',
    reporterName: json['reporterName'],
    reporter: ReporterInfo.fromJson(json['reporter'] ?? {}),
  );
}

const lostFoundTypeFilters = [
  {'value': 'all', 'label': 'All Items'},
  {'value': 'lost', 'label': 'Lost Items'},
  {'value': 'found', 'label': 'Found Items'},
];
