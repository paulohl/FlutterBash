import 'package:xueli/constants/app_constants.dart';

import 'english_name_model.dart';

class StudentModel {
  int id;
  String name;
  String gender;
  String phone;
  int school_id;
  int class_id;
  int english_id;
  EnglishNameModel? englishNameModel;
  int format_seven_sort;
  String eight_group;
  int eight_sort;

  StudentModel({
    required this.id,
    required this.name,
    required this.gender,
    required this.school_id,
    required this.phone,
    required this.class_id,
    required this.english_id,
    required this.englishNameModel,
    required this.format_seven_sort,
    required this.eight_sort,
    required this.eight_group,
  });

  factory StudentModel.fromMap(dynamic data) {
    return StudentModel(
      id: data["id"] ?? 0,
      name: data["name"] ?? "",
      gender: data["gender"] ?? "",
      school_id: data["school_id"] ?? 0,
      phone: data["phone"] ?? "",
      eight_group: data["eight_group"] ?? "",
      class_id: data["class_id"] ?? 0,
      english_id: data["english_id"] ?? 0,
      format_seven_sort: data["format_seven_sort"] ?? 0,
      eight_sort: data["eight_sort"] ?? 0,
      englishNameModel: data["EnglishName"] != null
          ? EnglishNameModel.fromMap(data["EnglishName"])
          : null,
    );
  }

  int getFormat8BoxId(int session) {
    var sessionReminder = session % 60;
    var roundReminder = sessionReminder % 5;
    var addNumber = roundReminder == 0 ? 5 : roundReminder;
    addNumber -= 1;
    var number = addNumber + eight_sort;
    var adjustedNumber = number;
    if (number > 5) {
      // to round number back
      adjustedNumber = number % 5;
    }
    if (sessionReminder == 0) {
      sessionReminder = 60;
    }
    // print(
    //     "session1 ${number}, $adjustedNumber, $sessionReminder, $roundReminder");

    if (eight_group == GroupNames.red) {
      if (sessionReminder > 5) {
        final multipleOfFive =
            sessionReminder - (roundReminder == 0 ? 5 : roundReminder);

        adjustedNumber += multipleOfFive;
        // print("session2 $multipleOfFive, $adjustedNumber");
      }
    } else if (eight_group == GroupNames.orange) {
      adjustedNumber += 10;
      if (session > 5) {
        final multipleOfFive =
            sessionReminder - (roundReminder == 0 ? 5 : roundReminder);
        adjustedNumber = adjustedNumber + multipleOfFive;
      }
      if (adjustedNumber > 60) {
        adjustedNumber -= 60;
      }
    } else if (eight_group == GroupNames.yellow) {
      adjustedNumber += 20;
      if (session > 5) {
        final multipleOfFive =
            sessionReminder - (roundReminder == 0 ? 5 : roundReminder);
        adjustedNumber = adjustedNumber + multipleOfFive;
      }
      if (adjustedNumber > 60) {
        adjustedNumber -= 60;
      }
    } else if (eight_group == GroupNames.green) {
      adjustedNumber += 30;
      if (session > 5) {
        final multipleOfFive =
            sessionReminder - (roundReminder == 0 ? 5 : roundReminder);
        adjustedNumber = adjustedNumber + multipleOfFive;
      }
      if (adjustedNumber > 60) {
        adjustedNumber -= 60;
      }
    } else if (eight_group == GroupNames.blue) {
      adjustedNumber += 40;
      if (session > 5) {
        final multipleOfFive =
            sessionReminder - (roundReminder == 0 ? 5 : roundReminder);
        adjustedNumber = adjustedNumber + multipleOfFive;
      }
      if (adjustedNumber > 60) {
        adjustedNumber -= 60;
      }
    } else if (eight_group == GroupNames.purple) {
      adjustedNumber += 50;
      if (session > 5) {
        final multipleOfFive =
            sessionReminder - (roundReminder == 0 ? 5 : roundReminder);
        adjustedNumber = adjustedNumber + multipleOfFive;
      }
      if (adjustedNumber > 60) {
        adjustedNumber -= 60;
      }
    }

    if (session > 60 && session < 121) {
      adjustedNumber += 60;
    } else if (session > 120 && session < 181) {
      adjustedNumber += 120;
    } else if (session > 180 && session < 241) {
      adjustedNumber += 180;
    } else if (session > 240 && session < 301) {
      adjustedNumber += 240;
    }
    return adjustedNumber;
  }

  String getBoxTitle(int session) {
    final boxId = getFormat8BoxId(session);
    var level = 1;
    if (boxId > 60 && boxId < 121) {
      level = 2;
    } else if (boxId > 120 && boxId < 181) {
      level = 3;
    } else if (boxId > 180 && boxId < 241) {
      level = 4;
    } else if (boxId > 240 && boxId < 301) {
      level = 5;
    }
    var reminder = boxId % 60;
    var group = "F";
    if (reminder > 0 && reminder < 11) {
      group = "A";
    } else if (reminder > 10 && reminder < 21) {
      group = "B";
    } else if (reminder > 20 && reminder < 31) {
      group = "C";
    } else if (reminder > 30 && reminder < 41) {
      group = "D";
    } else if (reminder > 40 && reminder < 51) {
      group = "E";
    }
    var tenReminder = boxId % 10;
    var fiveReminder = boxId % 5;
    var sText = "";
    if (tenReminder == 0 || tenReminder > 5) {
      sText = "S";
    }
    var number = fiveReminder == 0 ? 5 : fiveReminder;
    return "$group$sText$level-$number";
  }
}
