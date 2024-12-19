class AppVersion {
  String android;
  String ios;

  AppVersion({
    required this.android,
    required this.ios,
  });

  factory AppVersion.fromJSON(dynamic data) {
    return AppVersion(
      android: data["android"] ?? "0",
      ios: data["ios"] ?? "0",
    );
  }
}
