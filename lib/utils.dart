class Utils {
  static String representNumber(int number) => (number <= 9 ? "0" : "") + number.toString();
  static String representDateTime(DateTime dt) =>
    "${representNumber(dt.year)}-${representNumber(dt.month)}-${representNumber(dt.day)} ${representNumber(dt.hour)}:${representNumber(dt.minute)}";
  static String dayFromToday(DateTime dt, {bool includeTime = false}) {
    DateTime now = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    bool isBeforeOrNow (DateTime _d) => _d.isBefore(dt) || _d.isAtSameMomentAs(dt);
    String result = "";

    if(isBeforeOrNow(now)) {
      result = "Azi";
    }
    else if(isBeforeOrNow(now.subtract(const Duration(days: 1)))) {
      result = "Ieri";
    }
    else if(isBeforeOrNow(now.subtract(const Duration(days: 2)))) {
      result = "Alaltăieri";
    }

    if(result.isNotEmpty) {
      if (includeTime) {
        result += " ${representNumber(dt.hour)}:${representNumber(dt.minute)}";
      }
      return result;
    }

    return representDateTime(dt);
  }
}