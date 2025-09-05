import 'package:cached_network_image/cached_network_image.dart';
import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/widgets/cross_fade_box.dart';
import 'package:flutter/material.dart';

class NamedAvatar extends StatefulWidget {
  final bool loading;
  final String? imageUrl;
  final String name;
  final double size;
  final void Function()? onTap;
  final bool border;
  final Color? backgroundColor;

  const NamedAvatar({
    super.key,
    required this.loading,
    this.imageUrl,
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
            : widget.imageUrl != null
            ? CachedNetworkImage(
                imageUrl: widget.imageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) {
                  return ColorFadeBox(
                    width: widget.size,
                    height: widget.size,
                    borderRadius: BorderRadius.circular(widget.size / 2),
                  );
                },
                errorWidget: (context, url, error) => Icon(
                  Icons.broken_image_rounded,
                  color: Colors.white,
                  size: widget.size * 0.40,
                ),
              )
            : Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: AppColors.containerBg,
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
