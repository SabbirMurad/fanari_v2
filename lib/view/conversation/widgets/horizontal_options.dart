import 'package:fanari_v2/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HorizontalOptions extends StatefulWidget {
  final List<String> options;
  final String? selectedOption;
  final double? horizontalPadding;
  final Function(String)? onChange;

  const HorizontalOptions({
    super.key,
    required this.options,
    this.horizontalPadding,
    this.selectedOption,
    this.onChange,
  });

  @override
  State<HorizontalOptions> createState() => _HorizontalOptionsState();
}

class _HorizontalOptionsState extends State<HorizontalOptions> {
  late String _selectedOption;

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.selectedOption ?? widget.options.first;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: widget.horizontalPadding ?? 20.w),
            ...widget.options.map((option) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedOption = option;
                  });
                  widget.onChange?.call(option);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 372),
                  height: 32.h,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  margin: EdgeInsets.only(right: 12.w),
                  decoration: BoxDecoration(
                    color: _selectedOption == option
                        ? AppColors.primary
                        : AppColors.secondary,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Center(
                    child: Text(
                      option,
                      style: TextStyle(
                        color: _selectedOption == option
                            ? Colors.white
                            : AppColors.text,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
            SizedBox(width: widget.horizontalPadding ?? 20.w),
          ],
        ),
      ),
    );
  }
}
