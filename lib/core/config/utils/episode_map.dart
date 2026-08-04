// 1. Enum định nghĩa màu và text hiển thị
import 'dart:ui';

import 'package:flutter/material.dart';

enum MediaTagType {
  vietsub,
  longTieng,
  thuyetMinh;

  String get label {
    switch (this) {
      case MediaTagType.vietsub:
        return 'PĐ';
      case MediaTagType.longTieng:
        return 'LT';
      case MediaTagType.thuyetMinh:
        return 'TM';
    }
  }

  Color get color {
    switch (this) {
      case MediaTagType.vietsub:
        return Color(0xff5F6070);
      case MediaTagType.longTieng:
        return Color(0xff1568CF);
      case MediaTagType.thuyetMinh:
        return Color(0xff2DA35D);
    }
  }
}

// 2. Extension để tách chuỗi từ API (Vd: "Vietsub + Lồng Tiếng" -> List)
extension ConvertLangParser on String {
  List<MediaTagType> toMediaTags() {
    final value = _normalizeLangText(this);
    final tags = <MediaTagType>[];
    if (value.contains('vietsub') ||
        value.contains('phu de') ||
        value.contains('phu-de') ||
        value.contains('subtitle') ||
        RegExp(r'(^|[^a-z])vs([^a-z]|$)').hasMatch(value)) {
      tags.add(MediaTagType.vietsub);
    }
    if (value.contains('long tieng') ||
        value.contains('long-tieng') ||
        value.contains('long_tieng') ||
        RegExp(r'(^|[^a-z])lt([^a-z]|$)').hasMatch(value)) {
      tags.add(MediaTagType.longTieng);
    }
    if (value.contains('thuyet minh') ||
        value.contains('thuyet-minh') ||
        value.contains('thuyet_minh') ||
        RegExp(r'(^|[^a-z])tm([^a-z]|$)').hasMatch(value)) {
      tags.add(MediaTagType.thuyetMinh);
    }
    return tags;
  }

  String _normalizeLangText(String value) {
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

class EpisodeFormatter {
  static String toShort(String rawEp) {
    // String đầu vào có thể null hoặc rỗng thì return rỗng
    if (rawEp.isEmpty) return '';

    // CASE 1: Xử lý "Hoàn Tất (3/3)" -> Lấy số đầu tiên trong ngoặc
    // Logic: Tìm cụm có dạng (số/...)
    if (rawEp.toLowerCase().contains('hoàn tất')) {
      final match = RegExp(r'\((\d+)').firstMatch(rawEp);
      if (match != null) {
        // match.group(1) chính là con số tìm được (ví dụ 3)
        return 'T.${match.group(1)}';
      }
    }

    // CASE 2: Xử lý "Tập 3", "Tập 10"... -> Lấy số ra
    // Logic: Tìm chuỗi số (\d+) đầu tiên xuất hiện
    final match = RegExp(r'(\d+)').firstMatch(rawEp);
    if (match != null) {
      return 'T.${match.group(0)}';
    }

    // CASE 3: Các trường hợp đặc biệt khác (Full, Trailer...)
    // Nếu muốn giữ nguyên thì return rawEp, nếu muốn rút gọn thì tùy chỉnh thêm
    if (rawEp.toLowerCase() == 'full') return 'Full';

    return rawEp;
  }
}
