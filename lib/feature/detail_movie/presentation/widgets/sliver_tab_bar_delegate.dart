import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'package:movie_app/core/config/themes/app_color.dart';

class SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final Key? key;
  final GlobalKey _tabBarMarkerKey = GlobalKey();
  SliverTabBarDelegate(this._tabBar, {this.key});

  @override
  double get minExtent => _tabBar.preferredSize.height + 6;

  @override
  double get maxExtent => _tabBar.preferredSize.height + 6;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xff272A39), const Color(0xff191A24)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.12))),
      ),
      padding: const EdgeInsets.only(left: 16),
      alignment: Alignment.centerLeft,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(SliverTabBarDelegate oldDelegate) {
    return true;
  }
}
