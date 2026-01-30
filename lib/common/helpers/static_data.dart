import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StaticData {
  static List<String> country = [
    "Phim Hàn Quốc Mới Nhất",
    "Phim Trung Quốc Mới Nhất",
    "Phim UK-US Mới Nhất",
  ];

  static List<Map<LinearGradient, Color>> randomeGadientTitlePage = [
    {
      LinearGradient(
        colors: [Color(0xffA088BD), AppColor.bgApp, ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ) : Color(0xffA088BD)
    },
    {
      LinearGradient(
        colors: [Color(0xffEDCF82), AppColor.bgApp, ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ) : Color(0xffEDCF82)
    },
    {
      LinearGradient(
        colors: [Color(0xff8697E4), AppColor.bgApp, ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ) : Color(0xff8697E4)
    },
    {
      LinearGradient(
        colors: [Color(0xff7CB7A8), AppColor.bgApp, ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ) : Color(0xff7CB7A8)
    },
    {
      LinearGradient(
        colors: [Color(0xffE4B9A8), AppColor.bgApp, ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ) : Color(0xffE4B9A8)
    },
    {
      LinearGradient(
        colors: [Color(0xffC78181), AppColor.bgApp, ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ) : Color(0xffC78181)
    },
    {
      LinearGradient(
        colors: [Color(0xffD383AC), AppColor.bgApp, ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ) : Color(0xffD383AC)
    },
  ];
}
