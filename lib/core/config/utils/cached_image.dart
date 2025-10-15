import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:movie_app/common/components/loading/custom_loading.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CachedImageContainer extends StatefulWidget {
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
    this.isLoading = false,
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
  final bool isLoading;

  @override
  State<CachedImageContainer> createState() => _CachedImageContainerState();
}

class _CachedImageContainerState extends State<CachedImageContainer> {
  @override
  Widget build(BuildContext context) {
    return  CachedNetworkImage(
 
      imageUrl: widget.imageUrl,

      imageBuilder: (context, imageProvider) {
        return Container(
          height: widget.height,
          width: widget.width,
          margin: widget.margin,
          padding: widget.padding, 
          decoration: BoxDecoration(
            image: DecorationImage(image: imageProvider, fit: widget.boxFit),
            gradient: widget.gradient,
            border: widget.border,
            boxShadow: widget.boxShadow,
            borderRadius: widget.borderRadius,
          ),
        );
      },
      placeholder: (context, url) => Skeletonizer(child: SizedBox()),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}
