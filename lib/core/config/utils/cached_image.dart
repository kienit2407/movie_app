import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:movie_app/common/components/loading/custom_loading.dart';

class CachedImageContainer extends StatelessWidget {
  const CachedImageContainer({
    super.key,
    required this.imageUrl,
    this.boxFit,
    this.height,
    this.width,
    this.border,
    this.borderRadius,
    this.boxShadow,
    this.gradient,
    this.margin,
    this.padding,
  });
  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit? boxFit;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;
  final BoxBorder? border;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) {
        return Container(
          height: height,
          width: width,
          margin: margin,
          padding: padding,
          decoration: BoxDecoration(
            image: DecorationImage(image: imageProvider, fit: boxFit),
            gradient: gradient,
            border: border,
            boxShadow: boxShadow,
            borderRadius: borderRadius,
          ),
        );
      },
      placeholder: (context, url) => CustomLoading(splash: true,),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}
