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
      fullName: (json['fullName'] ?? json['full_name']) as String?,
      email: json['email'] as String?,
      universityName: (json['universityName'] ?? json['university_name']) as String?,
      mobileNumber: (json['mobileNumber'] ?? json['mobile_number']) as String?,
      department: json['department'] as String?,
      role: ((json['role'] ?? 'normal') as String?) ?? 'normal',
      onboardingCompleted: ((json['onboardingCompleted'] ?? json['onboarding_completed']) as bool?) ?? false,
      avatarUrl: (json['avatarUrl'] ?? json['avatar_url']) as String?,
      createdAt: json['createdAt'] != null || json['created_at'] != null
          ? DateTime.tryParse((json['createdAt'] ?? json['created_at']) as String)
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
