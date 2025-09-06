import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/model/poll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PollWidget extends StatefulWidget {
  final EdgeInsetsGeometry? padding;
  final PollModel model;

  const PollWidget({super.key, required this.model, this.padding});

  @override
  State<PollWidget> createState() => _PollWidgetState();
}

class _PollWidgetState extends State<PollWidget> {
  List<String> _chars = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: widget.padding,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Q.',
                style: TextStyle(color: AppColors.text, fontSize: 18.sp),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  widget.model.question,
                  style: TextStyle(color: AppColors.text, fontSize: 18.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          ...widget.model.options.asMap().entries.map((entry) {
            final item = entry.value;
            final index = entry.key;
            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.textDeemed),
                borderRadius: BorderRadius.circular(8.r),
              ),
              margin: EdgeInsets.only(top: 12.h),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.w),
              child: Row(
                children: [
                  Text(
                    '${_chars[index]}.',
                    style: TextStyle(color: AppColors.text, fontSize: 14.sp),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    item.text,
                    style: TextStyle(color: AppColors.text, fontSize: 14.sp),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
