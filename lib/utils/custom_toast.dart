part of '../utils.dart';

enum ToastTypes { success, error, warning, info }

class ToastTypesInfo {
  final ToastTypes type;
  late Color color;
  late ImageProvider image;

  ToastTypesInfo(this.type) {
    switch (type) {
      case ToastTypes.success:
        color = Colors.green;
        image = const AssetImage('assets/icons/success.png');
        break;
      case ToastTypes.error:
        color = Colors.red;
        image = const AssetImage('assets/icons/error.png');
        break;
      case ToastTypes.warning:
        color = Colors.orange;
        image = const AssetImage('assets/icons/warning.png');
        break;
      case ToastTypes.info:
        color = Colors.blue;
        image = const AssetImage('assets/icons/info.png');
        break;
    }
  }
}

class CustomToastNotification extends StatefulWidget {
  final String text;
  final int duration;
  final void Function()? onCloseClick;
  final ToastTypesInfo toastType;

  const CustomToastNotification({
    super.key,
    required this.text,
    required this.toastType,
    this.duration = 3000,
    this.onCloseClick,
  });

  @override
  _CustomToastNotificationState createState() =>
      _CustomToastNotificationState();
}

class _CustomToastNotificationState extends State<CustomToastNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Timer _timer;
  late int timeLeft;
  double progress = 1.0;

  @override
  void initState() {
    super.initState();
    timeLeft = widget.duration;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.duration),
    )..forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    });

    startProgress();
    _togglePosition();
  }

  void startProgress() {
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() {
        if (timeLeft <= 0) {
          _timer.cancel();
        } else {
          timeLeft = timeLeft - 10;
          setState(() {
            progress = timeLeft / widget.duration;
          });
        }
      });
    });
  }

  bool _isRightPosition = false;

  void _togglePosition() {
    setState(() {
      _isRightPosition = !_isRightPosition;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
        // boxShadow: [
        //   BoxShadow(
        //     color: Theme.of(context).colorScheme.tertiary.withValues(alpha:0.1),
        //     blurRadius: 12,
        //     spreadRadius: 2,
        //   ),
        // ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image(
            image: widget.toastType.image,
            height: 32,
            width: 32,
            color: widget.toastType.color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: Text(
                widget.text,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.tertiary,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          GestureDetector(
            onTap: () {
              widget.onCloseClick?.call();
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.close, color: widget.toastType.color, size: 16),
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: widget.toastType.color,
                    value: progress,
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

void showCustomToast({
  int duration = 3000,
  required String text,
  ToastTypesInfo? toastType,
}) {
  final snackBar = SnackBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    content: CustomToastNotification(
      text: text,
      duration: duration,
      toastType: toastType ?? ToastTypesInfo(ToastTypes.error),
      onCloseClick: () {
        ScaffoldMessenger.of(scaffoldKey.currentContext!).hideCurrentSnackBar();
      },
    ),
  );

  rootScaffoldMessengerKey.currentState?.showSnackBar(snackBar);
}
