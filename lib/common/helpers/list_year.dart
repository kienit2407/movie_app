class YearHelper {
  static List<String> getYears() {
    final currentYear = DateTime.now().year;
    // Tạo danh sách từ 1970 đến năm hiện tại
    return List<String>.generate(
      currentYear - 2000 + 1, // Tổng số năm cần có
      (index) => (currentYear - index).toString(),
    );
  }
}