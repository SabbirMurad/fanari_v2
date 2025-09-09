import 'package:fanari_v2/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:load_switch/load_switch.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomSwitch extends StatefulWidget {
  const CustomSwitch({super.key});

  @override
  State<CustomSwitch> createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> {
  bool value = false;

  @override
  Widget build(BuildContext context) {
    return LoadSwitch(
      value: value,
      width: 36.w,
      height: 16.w,
      future: () async {
        return await Future.delayed(Duration(milliseconds: 500), () {
          return !value;
        });
      },
      style: SpinStyle.material,
      curveIn: Curves.easeInBack,
      curveOut: Curves.easeOutBack,
      animationDuration: const Duration(milliseconds: 500),
      switchDecoration: (value, value2) => BoxDecoration(
        color: value
            ? AppColors.primary.withValues(alpha: 0.5)
            : AppColors.hintText.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(30),
        shape: BoxShape.rectangle,
        boxShadow: [
          BoxShadow(
            color: value
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.hintText.withValues(alpha: 0.1),
            spreadRadius: 5,
            blurRadius: 4,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      spinColor: (value) => value ? AppColors.primary : AppColors.hintText,
      spinStrokeWidth: 1,
      thumbDecoration: (value, value2) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        shape: BoxShape.rectangle,
        boxShadow: [
          BoxShadow(
            color: value
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.hintText.withValues(alpha: 0.1),
            spreadRadius: 5,
            blurRadius: 4,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      onChange: (v) {
        value = v;
        print('Value changed to $v');
        setState(() {});
      },
      onTap: (v) {
        print('Tapping while value is $v');
      },
    );
  }
}
