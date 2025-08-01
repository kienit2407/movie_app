import 'package:custom_check_box/custom_check_box.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:movie_app/core/config/themes/app_color.dart';

class AppCheckBox extends StatefulWidget {
  const AppCheckBox({
    super.key, 
    required this.isChecked,
    required this.onChanged
  });
  final bool isChecked;
  final ValueChanged<bool?> onChanged;
  @override
  State<AppCheckBox> createState() => _AppCheckBoxState();
}

class _AppCheckBoxState extends State<AppCheckBox> {
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
      Checkbox(
            value: widget.isChecked,
            activeColor: AppColor.secondColor,
            checkColor: Colors.white,
            shape: ContinuousRectangleBorder(borderRadius: BorderRadiusGeometry.circular(10)),
            onChanged: widget.onChanged
          ),
        Text('Remember me',
          style: TextStyle(
            fontWeight: FontWeight.w600
          ),
        ),
      ],
    );
  }
}
// Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Container(
//           width: 20,
//           height: 20,
//           decoration: BoxDecoration(
//             color: AppColor.secondColor
//           ),
//           child: Checkbox(
//             value: false,
//             activeColor: AppColor.secondColor,
//             checkColor: Colors.white,
            
//             onChanged: (value) {},
//           ),
//         ),
//         Text('Remember me'),
//       ],
//     );