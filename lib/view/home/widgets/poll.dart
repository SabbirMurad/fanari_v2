import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/model/poll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fanari_v2/utils.dart';

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

  late List<int> _selectedIndexes = widget.model.selected_options;

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

            final percent = ((item.vote * 100) / widget.model.total_vote)
                .toStringAsFixed(2);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    if (_selectedIndexes.contains(index)) {
                      setState(() {
                        _selectedIndexes.remove(index);
                      });
                    } else {
                      setState(() {
                        _selectedIndexes.add(index);
                      });
                    }
                  },
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                    margin: EdgeInsets.only(top: 12.h),
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Container(
                          height: 48.h,
                          width:
                              double.tryParse(percent)! * ((1.sw - 40.w) / 100),
                          decoration: BoxDecoration(
                            color: _selectedIndexes.contains(index)
                                ? AppColors.primary.withValues(alpha: 0.5)
                                : _selectedIndexes.isNotEmpty
                                ? AppColors.secondary.withValues(alpha: 0.8)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        Container(
                          height: 48.h,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _selectedIndexes.contains(index)
                                  ? AppColors.primary
                                  : AppColors.textDeemed,
                            ),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: Row(
                            children: [
                              Text(
                                '${_chars[index]}.',
                                style: TextStyle(
                                  color: AppColors.text,
                                  fontSize: 14.sp,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                item.text,
                                style: TextStyle(
                                  color: AppColors.text,
                                  fontSize: 14.sp,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_selectedIndexes.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(left: 8.w, top: 6.h),
                    child: Text(
                      '${percent}%',
                      style: TextStyle(color: AppColors.text, fontSize: 13.sp),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
