import 'package:fanari_v2/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InputFieldVOne extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isPasswordField;
  final String? error;
  final InputBorder? border;

  const InputFieldVOne({
    super.key,
    required this.hintText,
    required this.controller,
    this.isPasswordField = false,
    this.border,
    this.error,
  });

  @override
  State<InputFieldVOne> createState() => _InputFieldVOneState();
}

class _InputFieldVOneState extends State<InputFieldVOne> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();

  bool _hasFocus = false;
  @override
  void initState() {
    super.initState();

    setState(() {
      _obscureText = widget.isPasswordField;
    });

    _focusNode.addListener(() {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  bool _obscureText = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          height: 56.h,
          child: TextField(
            obscureText: _obscureText,
            focusNode: _focusNode,
            controller: widget.controller,

            decoration: InputDecoration(
              isDense: true,
              errorText: widget.error,
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.error,
                  width: 1,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
              hintText: _hasFocus ? '' : widget.hintText,
              border:
                  widget.border ??
                  OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.text, width: 1),
                    gapPadding: 4.w,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
              labelText: widget.hintText,
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              enabledBorder:
                  widget.border ??
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: AppColors.text, width: 1),
                  ),
              labelStyle: TextStyle(color: AppColors.text, fontSize: 16.sp),
            ),
            style: TextStyle(color: AppColors.text, fontSize: 16.sp),
          ),
        ),
        if (widget.isPasswordField)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: IconButton(
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
              icon: Icon(
                _obscureText ? Icons.remove_red_eye : Icons.visibility_off,
                color: AppColors.text,
              ),
            ),
          ),
      ],
    );
  }
}
