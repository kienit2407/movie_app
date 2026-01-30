import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class CoverMap {
  static const Map<String, Map<String, dynamic>> coverMap = {
    "vietsub": {
      "title": "Phụ Đề",
      "icon": Iconsax.subtitle,
      "color": Color(0xFF5F6070), // Màu xanh
    },
    "longtieng": {
      "title": "Lồng Tiếng",
      "icon": Iconsax.microphone,
      "color": Color(0xFF1D2E7A), // Màu đỏ
    },
    "thuyetminh": {
      "title": "Thuyết Minh",
      "icon": Iconsax.sound,
      "color": Color(0xFF297547), // Màu đỏ
    },
  };
  // Hàm quan trọng: Chuyển tên server thành Key của Map
  static Map<String, dynamic> getConfigFromServerName(String input) {
    String name = input.toLowerCase();

    // Ưu tiên Thuyết Minh và Lồng Tiếng trước vì Vietsub thường là mặc định
    if (name.contains("thuyết minh") || name.contains("thuyet minh")) {
      return coverMap["thuyetminh"]!;
    } else if (name.contains("lồng tiếng") || name.contains("long tieng")) {
      return coverMap["longtieng"]!;
    } else if (name.contains("vietsub") || name.contains("phụ đề")) {
      return coverMap["vietsub"]!;
    }

    return coverMap["vietsub"]!;
  }
}
