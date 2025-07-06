class UserPreferences {
  final String avatarUrl;
  final String themeColor;

  UserPreferences({
    required this.avatarUrl,
    required this.themeColor,
  });

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      avatarUrl: map['avatarUrl'] ?? '',
      themeColor: map['themeColor'] ?? 'blue',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'avatarUrl': avatarUrl,
      'themeColor': themeColor,
    };
  }

  @override
  String toString() => 'UserPreferences(avatarUrl: $avatarUrl, themeColor: $themeColor)';
}
