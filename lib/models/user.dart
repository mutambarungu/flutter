class User {
  String id;
  String email;
  String password;
  String firstName;
  String lastName;
  DateTime createdOn;

  User({
    required this.id,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.createdOn,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
      'created_on': createdOn.toIso8601String(),
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      password: map['password'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      createdOn: DateTime.parse(map['created_on']),
    );
  }
}
