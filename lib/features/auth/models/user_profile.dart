/// User profile model matching backend `/profiles/me` response.
class UserProfile {
  final String id;
  final String? fullName;
  final String? email;
  final String? universityName;
  final String? mobileNumber;
  final String? department;
  final String role;
  final bool onboardingCompleted;
  final String? avatarUrl;
  final DateTime? createdAt;

  const UserProfile({
    required this.id,
    this.fullName,
    this.email,
    this.universityName,
    this.mobileNumber,
    this.department,
    this.role = 'normal',
    this.onboardingCompleted = false,
    this.avatarUrl,
    this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      fullName: json['fullName'] as String?,
      email: json['email'] as String?,
      universityName: json['universityName'] as String?,
      mobileNumber: json['mobileNumber'] as String?,
      department: json['department'] as String?,
      role: (json['role'] as String?) ?? 'normal',
      onboardingCompleted: (json['onboardingCompleted'] as bool?) ?? false,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'universityName': universityName,
        'mobileNumber': mobileNumber,
        'department': department,
        'role': role,
        'onboardingCompleted': onboardingCompleted,
        'avatarUrl': avatarUrl,
      };
}
