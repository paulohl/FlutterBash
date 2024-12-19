class ForgettingCurveModel {
  int id;
  int day;

  ForgettingCurveModel({
    required this.id,
    required this.day,
  });

  factory ForgettingCurveModel.fromMap(dynamic data) {
    return ForgettingCurveModel(
      id: data["id"] ?? 0,
      day: data["day"] ?? 0,
    );
  }
}
