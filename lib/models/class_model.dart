class ClassModel {
  int id;
  String name;
  String startTime;
  String endTime;
  int school_id;

  ClassModel({
    required this.name,
    required this.id,
    required this.endTime,
    required this.school_id,
    required this.startTime,
  });

  factory ClassModel.fromMap(dynamic data) {
    return ClassModel(
      name: data["name"] ?? "",
      id: data["id"] ?? 0,
      endTime: data["end_time"] ?? "",
      school_id: data["school_id"] ?? 0,
      startTime: data["start_time"] ?? "",
    );
  }
}
