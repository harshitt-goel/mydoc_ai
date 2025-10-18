class ProfileData {
  final int age;
  final String gender;
  final String activityLevel;
  final List<String> medicalConditions;
  final double? heightCm;
  final double? weightKg;

  ProfileData({
    required this.age,
    required this.gender,
    required this.activityLevel,
    required this.medicalConditions,
    this.heightCm,
    this.weightKg,
  });

  Map<String, dynamic> toJson() => {
    'age': age,
    'gender': gender,
    'activityLevel': activityLevel,
    'medicalConditions': medicalConditions,
    'heightCm': heightCm,
    'weightKg': weightKg,
  };

  factory ProfileData.fromJson(Map<String, dynamic> json) => ProfileData(
    age: json['age'],
    gender: json['gender'],
    activityLevel: json['activityLevel'],
    medicalConditions:
    List<String>.from(json['medicalConditions'] ?? <String>[]),
    heightCm: (json['heightCm'] as num?)?.toDouble(),
    weightKg: (json['weightKg'] as num?)?.toDouble(),
  );
}
