class UserModel {
  final String id;
  final String name;
  final String? studentId;
  final String email;
  final String? department;
  final String? semester;
  final String? batch;
  final String? contactNumber;
  final String role;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    this.studentId,
    required this.email,
    this.department,
    this.semester,
    this.batch,
    this.contactNumber,
    required this.role,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      studentId: json['student_id'],
      email: json['email'] ?? '',
      department: json['department'],
      semester: json['semester'],
      batch: json['batch'],
      contactNumber: json['contact_number'],
      role: json['role'] ?? 'student',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'student_id': studentId,
      'email': email,
      'department': department,
      'semester': semester,
      'batch': batch,
      'contact_number': contactNumber,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
