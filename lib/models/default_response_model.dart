class DefaultResponseModel {
  bool success;
  String message;
  String uid;

  DefaultResponseModel({
    required this.success,
    required this.message,
    required this.uid,
  });

  factory DefaultResponseModel.fromMap(dynamic data) {
    return DefaultResponseModel(
      success: data["success"] ?? false,
      message: data["message"] ?? "",
      uid: data["uid"] ?? "",
    );
  }
}
