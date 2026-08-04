import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';

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
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth = widget.width == null
        ? null
        : (widget.width! * pixelRatio).round().clamp(1, 1280).toInt();
    final cacheHeight = widget.height == null
        ? null
        : (widget.height! * pixelRatio).round().clamp(1, 1920).toInt();

    return Container(
      height: widget.height,
      width: widget.width,
      margin: widget.margin,
      padding: widget.padding,
      decoration: BoxDecoration(
        gradient: widget.gradient,
        border: widget.border,
        boxShadow: widget.boxShadow,
        borderRadius: widget.borderRadius,
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius as BorderRadius? ?? BorderRadius.zero,
        child: FastCachedImage(
          url: widget.imageUrl,
          fit: widget.boxFit ?? BoxFit.cover,
          width: widget.width,
          height: widget.height,
          cacheWidth: cacheWidth,
          cacheHeight: cacheHeight,
        ),
      ),
    );
  }
}
