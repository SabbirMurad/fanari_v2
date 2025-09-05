import 'package:fanari_v2/model/post.dart';
import 'package:fanari_v2/widgets/status_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PostWidget extends StatefulWidget {
  final PostModel model;

  const PostWidget({super.key, required this.model});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          if (widget.model.caption != null)
            StatusWidget(
              text: widget.model.caption!,
              width: 1.sw - 40.w,
              mentions: widget.model.mentions,
            ),
        ],
      ),
    );
  }
}
