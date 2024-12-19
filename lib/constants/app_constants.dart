class EnglishNumbers {
  static final List<NumberModel> list = [
    NumberModel(1, "First"),
    NumberModel(2, "Second"),
    NumberModel(3, "Third"),
    NumberModel(4, "Four"),
    NumberModel(5, "Five"),
    NumberModel(
      6,
      "Six",
    ),
    NumberModel(
      7,
      "Seven",
    ),
    NumberModel(
      8,
      "Eight",
    ),
    NumberModel(
      9,
      "Nine",
    ),
    NumberModel(
      10,
      "Ten",
    ),
    NumberModel(
      11,
      "Eleven",
    ),
    NumberModel(
      12,
      "Twelve",
    ),
    NumberModel(
      13,
      "Thirteen",
    ),
    NumberModel(
      14,
      "Fourteen",
    ),
    NumberModel(
      15,
      "Fifteen",
    ),
    NumberModel(
      16,
      "Sixteen",
    ),
    NumberModel(
      17,
      "Seventeen",
    ),
    NumberModel(
      18,
      "Eighteen",
    ),
  ];
}

class AudioMode {
  static String english = "ENG";
  static String chinese = "CHN";
  static String englishAndChinese = "ENG&CHN";
  static String chineseAndEnglish = "CHN&ENG";
}

class AppConstants {
  static var callModeChangeCount = 200;
}

class GroupNames {
  static var red = "Red";
  static var orange = "Orange";
  static var yellow = "Yellow";
  static var blue = "Blue";
  static var green = "Green";
  static var purple = "Purple";
}

class NumberModel {
  int id;
  String name;

  NumberModel(this.id, this.name);
}

class Formats {
  static String format1 = "Format 1";
  static String format2 = "Format 2";
  static String format3 = "Format 3";
  static String format4 = "Format 4";
  static String format5 = "Format 5";
  static String format6 = "Format 6";
  static String format7 = "Format 7";
  static String format8 = "Format 8";
}
