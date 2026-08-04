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
    final name = _normalize(input);

    final hasVietsub =
        name.contains('vietsub') ||
        name.contains('phu de') ||
        name.contains('phu-de') ||
        name.contains('subtitle') ||
        RegExp(r'(^|[^a-z])vs([^a-z]|$)').hasMatch(name);
    final hasLongTieng =
        name.contains('long tieng') ||
        name.contains('long-tieng') ||
        name.contains('long_tieng') ||
        RegExp(r'(^|[^a-z])lt([^a-z]|$)').hasMatch(name);
    final hasThuyetMinh =
        name.contains('thuyet minh') ||
        name.contains('thuyet-minh') ||
        name.contains('thuyet_minh') ||
        RegExp(r'(^|[^a-z])tm([^a-z]|$)').hasMatch(name);

    if ((hasVietsub && hasLongTieng) ||
        (hasVietsub && hasThuyetMinh) ||
        (hasLongTieng && hasThuyetMinh)) {
      final titles = <String>[
        if (hasVietsub) 'Phụ Đề',
        if (hasThuyetMinh) 'Thuyết Minh',
        if (hasLongTieng) 'Lồng Tiếng',
      ];
      return {
        ...coverMap[hasThuyetMinh
            ? 'thuyetminh'
            : hasLongTieng
            ? 'longtieng'
            : 'vietsub']!,
        'title': titles.join(' + '),
      };
    }

    // Ưu tiên Thuyết Minh và Lồng Tiếng trước vì Vietsub thường là mặc định
    if (hasThuyetMinh) {
      return coverMap["thuyetminh"]!;
    } else if (hasLongTieng) {
      return coverMap["longtieng"]!;
    } else if (hasVietsub) {
      return coverMap["vietsub"]!;
    }

    return coverMap["vietsub"]!;
  }

  static String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp('[àáạảãâầấậẩẫăằắặẳẵ]'), 'a')
        .replaceAll(RegExp('[èéẹẻẽêềếệểễ]'), 'e')
        .replaceAll(RegExp('[ìíịỉĩ]'), 'i')
        .replaceAll(RegExp('[òóọỏõôồốộổỗơờớợởỡ]'), 'o')
        .replaceAll(RegExp('[ùúụủũưừứựửữ]'), 'u')
        .replaceAll(RegExp('[ỳýỵỷỹ]'), 'y')
        .replaceAll('đ', 'd')
        .trim();
  }
}
