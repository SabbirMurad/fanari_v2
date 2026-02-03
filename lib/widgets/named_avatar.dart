import 'package:cached_network_image/cached_network_image.dart';
import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/model/image.dart';
import 'package:fanari_v2/widgets/cross_fade_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';

class NamedAvatar extends StatefulWidget {
  final bool loading;
  final ImageModel? image;
  final String name;
  final double size;
  final void Function()? onTap;
  final bool border;
  final Color? backgroundColor;

  const NamedAvatar({
    super.key,
    required this.loading,
    this.image,
    required this.name,
    required this.size,
    this.backgroundColor,
    this.onTap,
    this.border = false,
  });

  @override
  State<NamedAvatar> createState() => _NamedAvatarState();
}

class _NamedAvatarState extends State<NamedAvatar> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.size / 2),
        child: widget.loading
            ? ColorFadeBox(
                width: widget.size,
                height: widget.size,
                borderRadius: BorderRadius.circular(widget.size / 2),
              )
            : widget.image != null
            ? CachedNetworkImage(
                imageUrl: widget.image!.webp_url,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) {
                  return SizedBox(
                    width: widget.size,
                    height: widget.size,
                    child: BlurHash(
                      hash: widget.image!.blur_hash,
                      color: AppColors.secondary,
                      optimizationMode: BlurHashOptimizationMode.approximation,
                    ),
                  );
                },
                errorWidget: (context, url, error) => Icon(
                  Icons.broken_image_rounded,
                  color: AppColors.secondary,
                  size: widget.size * 0.40,
                ),
              )
            : Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: widget.backgroundColor ?? AppColors.secondary,
                  borderRadius: BorderRadius.circular(widget.size / 2),
                ),
                child: Center(
                  child: Text(
                    widget.name[0].toUpperCase(),
                    style: TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w500,
                      fontSize: widget.size * 0.48,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
