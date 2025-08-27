import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NamedAvatar extends StatefulWidget {
  final bool skeletonizer;
  final String? imageUrl;
  final String name;
  final double width;
  final void Function()? onTap;
  final bool border;
  final Color? backgroundColor;

  const NamedAvatar({
    super.key,
    required this.skeletonizer,
    required this.imageUrl,
    required this.name,
    required this.width,
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
      child: Container(
        width: widget.width,
        height: widget.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            widget.width / 2,
          ),
          color: widget.backgroundColor ??
              Theme.of(context).colorScheme.primaryContainer,
          border: widget.border
              ? Border.all(
                  color: Theme.of(context).colorScheme.tertiary,
                  width: 1,
                )
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            widget.width / 2,
          ),
          child: widget.imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: widget.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) {
                    return Container(
                      color: Theme.of(context).colorScheme.secondary,
                      width: widget.width,
                      height: widget.width,
                    );
                  },
                  errorWidget: (context, url, error) => Icon(
                    Icons.broken_image_rounded,
                    color: Colors.white,
                    size: widget.width * 0.40,
                  ),
                )
              : Center(
                  child: Text(
                    widget.name[0].toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
                      fontWeight: FontWeight.w500,
                      fontSize: widget.width * 0.48,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
