class Contact {
  final int? id; 
  final String name;
  final String phoneNumber;

  Contact({this.id, required this.name, required this.phoneNumber});

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
    };
  }

  factory Contact.fromMap(Map<String, Object?> map) {
    return Contact(
      id: map['id'] as int,
      name: map['name'] as String,
      phoneNumber: map['phone_number'] as String,
    );
  }
}