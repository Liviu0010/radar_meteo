class Utils {
  static String representNumber(int number) => (number <= 9 ? "0" : "") + number.toString();
  static String representDateTime(DateTime dt) =>
    "${representNumber(dt.year)}-${representNumber(dt.month)}-${representNumber(dt.day)} ${representNumber(dt.hour)}:${representNumber(dt.minute)}";
}