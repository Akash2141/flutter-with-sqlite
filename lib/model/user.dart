class User {
  int? id;
  String name;
  int age;
  String country;
  String? email;

  User(
      {this.id,
      required this.name,
      required this.age,
      required this.country,
      this.email});

  User.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        name = res["name"],
        age = res["age"],
        country = res["country"],
        email = res["email"];

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'country': country,
      'email': email
    };
  }
}
