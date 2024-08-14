class Prescription {
  final String id;
  final String userId;
  final String doctorId;
  final List<String> medicines;
  final DateTime date;

  Prescription({
    required this.id,
    required this.userId,
    required this.doctorId,
    required this.medicines,
    required this.date,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'],
      userId: json['userId'],
      doctorId: json['doctorId'],
      medicines: List<String>.from(json['medicines']),
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'doctorId': doctorId,
      'medicines': medicines,
      'date': date.toIso8601String(),
    };
  }
}
