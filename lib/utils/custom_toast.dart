part of '../utils.dart';

// ── Toast type ────────────────────────────────────────────────────────────────

enum ToastType { success, error, warning, info }

class _ToastStyle {
  final Color color;
  final SvgPicture icon;

  _ToastStyle({required this.color, required this.icon});

  static const String _info_svg =
      '<svg id="Layer_1" data-name="Layer 1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><path d="M256.42,512C115.51,512.45.42,397.73,0,256.41-.42,115.46,114.2.47,255.57,0,396.51-.46,511.49,114.14,512,255.57,512.5,396.48,397.82,511.55,256.42,512Zm-28-300c0,21.53,0,43.05,0,64.57,0,16.72,11.5,28.86,27.27,29,16,.14,27.86-12.09,27.87-29q.07-64.29,0-128.57c0-16.94-11.74-29.33-27.6-29.33S228.45,131,228.42,148Q228.38,180,228.41,212ZM224.72,366.1a31.17,31.17,0,1,0,31.07-31.32A31,31,0,0,0,224.72,366.1Z"/></svg>';

  static const String _success_svg =
      '<svg id="Layer_1" data-name="Layer 1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><path d="M261,0l4.19,2.3c7.27,4,11,11.61,9.79,20.2C274,30.09,268,36.82,260.1,38s-16.25,1.11-24.36,1.85a210.13,210.13,0,0,0-116.8,47.87c-36.56,30-62,67.8-73.07,114C27.89,276.42,44,343.49,95.15,401.3c34,38.43,77,61.82,127.63,69.21,65.79,9.61,124.74-7.12,175.39-50.72,34-29.25,56.68-65.81,68.09-109.24a205.06,205.06,0,0,0,6.85-49.29,51.24,51.24,0,0,1,.72-8.93c2-10.28,10.58-16.47,21.13-15.44a18.8,18.8,0,0,1,17,19c.11,40.8-8.8,79.58-27.71,115.73-35.9,68.65-91.36,113.78-166.48,132.64C182.78,538.1,46.87,458.23,9.39,323.79c-4.21-15.11-5.62-31-8.34-46.52-.25-1.46-.64-2.89-1-4.34v-34c.76-6.07,1.43-12.16,2.31-18.21,7.35-50.32,27.37-94.94,61-133.08,41.11-46.6,92.47-75,154-84.69,7.19-1.13,14.42-2,21.63-3Z"/><path d="M239.72,301.28c1.22-1.81,2.11-3.71,3.5-5.11Q355.3,184.24,467.42,72.37c6-6,12.55-9.81,21.4-7.36a19.25,19.25,0,0,1,10,30.43,45.87,45.87,0,0,1-3.73,4Q374.69,219.65,254.29,339.84c-6.34,6.34-13.36,10.23-22.32,6.91a25.27,25.27,0,0,1-9.31-6.37q-47.22-50.91-94.19-102.08c-4.37-4.73-7.33-9.9-6.75-16.53.71-8,4.86-13.83,12.38-16.62,7.9-2.94,15.19-1.2,21,4.93,8.15,8.56,16.07,17.34,24.08,26q28.44,30.87,56.88,61.73C236.85,298.68,237.73,299.4,239.72,301.28Z"/></svg>';

  static const String _warning_svg =
      '<svg id="Layer_1" data-name="Layer 1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><path d="M256.28,487.86q-100,0-199.91,0c-28.29,0-50.51-18.33-55.48-46.07-2.33-13,.27-25.35,6.85-36.91q39.07-68.57,78-137.22Q146.39,160.9,207,54.13c9.3-16.41,22.69-26.81,41.54-29.43,22.76-3.17,43.74,7.1,55.31,27.21,15.17,26.36,30.06,52.89,45.08,79.34q77.28,136.16,154.61,272.28c8.13,14.31,10.76,29.2,6,45.1-7.07,23.72-28.33,39.19-53.92,39.21Q356,487.9,256.28,487.86Zm34.77-303.43c.3-14.86-1-25.25-4.95-35.76-3.16-8.44-8.85-14.13-17.8-16.24-17.16-4-34.22,6.2-37.67,23.94-1.7,8.75-1.29,18.07-.8,27.07,1.63,29.88,3.61,59.74,5.68,89.59,1,14.54,1,29.26,6.18,43.22,3.21,8.6,9,12.78,17.87,12.72s15.54-4.11,17.54-12.92a275.58,275.58,0,0,0,5.21-34.21C285.46,249.39,288.17,216.9,291.05,184.43ZM228.28,385.87c-.08,17.58,13.16,30.66,31.08,30.7,17.52.05,30.76-12.79,30.8-29.86,0-17.79-13.48-31.76-30.86-31.89S228.36,368.38,228.28,385.87Z"/></svg>';

  factory _ToastStyle.from_type(ToastType type) {
    switch (type) {
      case ToastType.success:
        final color = Colors.green;
        return _ToastStyle(
          color: color,
          icon: SvgPicture.string(_success_svg, color: color, height: 20.w, width: 20.w),
        );
      case ToastType.error:
        final color = Colors.red;
        return _ToastStyle(
          color: color,
          icon: SvgPicture.string(_warning_svg, color: color, height: 20.w, width: 20.w),
        );
      case ToastType.warning:
        final color = Colors.orange;
        return _ToastStyle(
          color: color,
          icon: SvgPicture.string(_warning_svg, color: color, height: 20.w, width: 20.w),
        );
      case ToastType.info:
        final color = Colors.blue;
        return _ToastStyle(
          color: color,
          icon: SvgPicture.string(_info_svg, color: color, height: 20.w, width: 20.w),
        );
    }
  }
}

// ── Toast widget ──────────────────────────────────────────────────────────────

class _ToastContent extends StatefulWidget {
  final String text;
  final int duration_ms;
  final VoidCallback? on_close;
  final _ToastStyle style;

  const _ToastContent({
    super.key,
    required this.text,
    required this.style,
    this.duration_ms = 3000,
    this.on_close,
  });

  @override
  State<_ToastContent> createState() => _ToastContentState();
}

class _ToastContentState extends State<_ToastContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Timer _progress_timer;
  late int _time_left_ms;
  double _progress = 1.0;

  @override
  void initState() {
    super.initState();
    _time_left_ms = widget.duration_ms;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.duration_ms),
    )..forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    });

    _progress_timer = Timer.periodic(const Duration(milliseconds: 10), (_) {
      if (!mounted) return;
      setState(() {
        _time_left_ms = (_time_left_ms - 10).clamp(0, widget.duration_ms);
        _progress = _time_left_ms / widget.duration_ms;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _progress_timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xff242424).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          widget.style.icon,
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              widget.text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: widget.on_close,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.close, color: widget.style.color, size: 16),
                SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: CircularProgressIndicator(
                    color: widget.style.color,
                    value: _progress,
                    strokeWidth: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Public API ────────────────────────────────────────────────────────────────

void show_custom_toast({
  required String text,
  ToastType type = ToastType.error,
  int duration_ms = 3000,
}) {
  final style = _ToastStyle.from_type(type);

  final snack_bar = SnackBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    content: _ToastContent(
      text: text,
      style: style,
      duration_ms: duration_ms,
      on_close: () {
        rootScaffoldMessengerKey.currentState?.hideCurrentSnackBar();
      },
    ),
  );

  rootScaffoldMessengerKey.currentState?.showSnackBar(snack_bar);
}
