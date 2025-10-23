import 'package:fanari_v2/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomDropDown extends StatefulWidget {
  final String? title;
  final String selectedOption;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Color? iconColor;
  final Color? fillColor;
  final Color? borderColor;
  final List<String> options;
  final void Function(String)? onChanged;
  final Color? dropdownColor;
  final TextStyle? optionTextStyle;
  final Widget? icon;

  const CustomDropDown({
    super.key,
    this.title,
    this.fillColor,
    this.icon,
    this.optionTextStyle,
    required this.selectedOption,
    this.height,
    this.padding,
    this.iconColor,
    required this.options,
    this.borderColor,
    this.onChanged,
    this.dropdownColor,
  });

  @override
  State<CustomDropDown> createState() => _CustomDropDownState();
}

class _CustomDropDownState extends State<CustomDropDown> {
  late String _selectedOption = widget.selectedOption;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null)
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Text(
              widget.title!,
              style: TextStyle(
                color: AppColors.text,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        Container(
          width: double.infinity,
          padding: widget.padding ?? EdgeInsets.symmetric(horizontal: 16.w),
          height: widget.height ?? 48.h,
          decoration: BoxDecoration(
            color: widget.fillColor,
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(color: widget.borderColor ?? AppColors.border),
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            icon:
                widget.icon ??
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 24.w,
                  color: AppColors.text,
                ),
            style:
                widget.optionTextStyle ??
                TextStyle(
                  color: AppColors.text,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
            value: _selectedOption,
            elevation: 3,
            dropdownColor: widget.dropdownColor ?? AppColors.containerBg,
            underline: Container(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedOption = newValue;
                });

                widget.onChanged?.call(newValue);
              }
            },
            items: widget.options.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                alignment: Alignment.centerLeft,
                value: value,
                child: Text(
                  value,
                  style:
                      widget.optionTextStyle ??
                      TextStyle(
                        color: AppColors.text,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
