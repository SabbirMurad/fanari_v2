import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/widgets/svg_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum InputMessageType { error, loading, ok, info }

class InputMessage extends StatefulWidget {
  final String text;
  final InputMessageType type;

  const InputMessage({super.key, required this.text, required this.type});

  @override
  State<InputMessage> createState() => _InputMessageState();
}

class _InputMessageState extends State<InputMessage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.type == InputMessageType.error)
            Svg.asset('assets/icons/error.svg', width: 13.w),
          if (widget.type == InputMessageType.ok)
            Svg.asset('assets/icons/success.svg', width: 13.w),
          if (widget.type == InputMessageType.loading)
            Container(
              width: 13.w,
              height: 13.w,
              margin: EdgeInsets.only(top: 2),
              child: CircularProgressIndicator(
                color: Colors.grey[300],
                strokeWidth: 2,
              ),
            ),
          if (widget.type == InputMessageType.info)
            Container(
              margin: EdgeInsets.only(top: 2),
              child: Icon(
                Icons.info_rounded,
                color: AppColors.primary.withValues(alpha: .75),
                size: 13.w,
              ),
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.text,
              style: TextStyle(
                color: AppColors.text.withValues(alpha: .8),
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
