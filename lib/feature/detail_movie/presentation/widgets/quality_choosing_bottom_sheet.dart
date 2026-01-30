import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:movie_app/core/config/themes/app_color.dart';

class QualityChoosingBottomSheet extends StatefulWidget {
  final String? currentQuality;
  final Map<String, String>? availableQualities;

  const QualityChoosingBottomSheet({
    super.key,
    this.currentQuality,
    this.availableQualities,
  });

  static Future<String?> show(
    BuildContext context, {
    String? currentQuality,
    Map<String, String>? availableQualities,
  }) async {
    return await showModalBottomSheet<String>(
      sheetAnimationStyle: AnimationStyle(
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 300),
      ),
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => QualityChoosingBottomSheet(
        currentQuality: currentQuality,
        availableQualities: availableQualities,
      ),
    );
  }

  @override
  State<QualityChoosingBottomSheet> createState() =>
      _QualityChoosingBottomSheetState();
}

class _QualityChoosingBottomSheetState
    extends State<QualityChoosingBottomSheet> {
  late String? selectedQuality;
  late List<String> availableQualityList;

  @override
  void initState() {
    super.initState();
    selectedQuality = widget.currentQuality;
    availableQualityList = widget.availableQualities?.keys.toList() ??
        ['480p', '720p', '1080p', '4K'];
  }

  void _handleQualitySelection(String quality) {
    setState(() {
      selectedQuality = quality;
    });
    Navigator.pop(context, quality);
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.only(bottom: 40),
        decoration: BoxDecoration(
          color: const Color(0xff2F3345),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              width: 100,
              height: 5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                spacing: 5,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Iconsax.video, size: 16),
                  const Text(
                    'Chất lượng video',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              height: MediaQuery.of(context).size.height * .25,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColor.buttonColor),
                  bottom: BorderSide(color: AppColor.buttonColor),
                ),
              ),
              child: _buildQualitySelector(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQualitySelector() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: availableQualityList.length,
      separatorBuilder: (context, index) => const Divider(
        color: AppColor.buttonColor,
        thickness: 1,
        height: 1,
      ),
      itemBuilder: (context, index) {
        final quality = availableQualityList[index];
        final bool isSelected = selectedQuality == quality;
        return InkWell(
          onTap: () => _handleQualitySelection(quality),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              children: [
                Text(
                  quality,
                  style: TextStyle(
                    color: isSelected ? const Color(0xffF1D775) : Colors.white,
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  const Icon(
                    Iconsax.check,
                    size: 20,
                    color: Color(0xffF1D775),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
