class EvaluationModel {
  int id;
  int teacher_id;
  int teacher_common_id;
  String created_at;
  List<dynamic> list;
  List<dynamic> evaluation_result;

  EvaluationModel({
    required this.id,
    required this.teacher_id,
    required this.teacher_common_id,
    required this.created_at,
    required this.list,
    required this.evaluation_result,
  });

  factory EvaluationModel.fromMap(dynamic data) {
    return EvaluationModel(
      id: data["id"] ?? 0,
      created_at: data["created_at"] ?? "",
      teacher_id: data["teacher_id"] ?? 0,
      teacher_common_id: data["teacher_common_id"] ?? 0,
      list: data["list"] ?? [],
      evaluation_result: data["evaluation_result"] ?? [],
    );
  }
}
