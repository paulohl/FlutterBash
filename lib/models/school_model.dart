class SchoolModel {
  int id;
  String name;
  String email;
  String phone;
  String address;
  String city;
  String state;

  SchoolModel({
    required this.city,
    required this.address,
    required this.phone,
    required this.email,
    required this.name,
    required this.id,
    required this.state,
  });

  factory SchoolModel.fromMap(dynamic data) {
    return SchoolModel(
      city: data["city"] ?? "",
      address: data["address"] ?? "",
      phone: data["phone"] ?? "",
      email: data["email"] ?? "",
      name: data["name"] ?? "",
      id: data["id"] ?? 0,
      state: data["state"] ?? "",
    );
  }
}
