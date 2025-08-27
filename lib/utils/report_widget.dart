part of '../utils.dart';

void showReportWidget({required BuildContext context}) {
  showModalBottomSheet(
    backgroundColor: Colors.transparent,
    context: context,
    isScrollControlled: true,
    elevation: 0,
    builder: (context) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.transparent,
          child: Center(
            child: GestureDetector(
              onTap: () {
                // Do nothing here, this prevents the gesture detector of the whole container
              },
              child: ReportWidget(),
            ),
          ),
        ),
      );
    },
  );
}

class ReportWidget extends StatefulWidget {
  const ReportWidget({super.key});

  @override
  State<ReportWidget> createState() => _ReportWidgetState();
}

class _ReportWidgetState extends State<ReportWidget> {
  final TextEditingController _controller = TextEditingController();
  int charCount = 0;

  String? _selectedOption;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  TextStyle _reportOptionTextStyle() {
    return TextStyle(
      color: Theme.of(context).colorScheme.tertiary,
      fontSize: 14,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw - 24,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Report',
            style: TextStyle(
              color: Theme.of(context).colorScheme.tertiary,
              fontSize: 21,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Radio(
                    value: 'Spam or Misinformation',
                    groupValue: _selectedOption,
                    fillColor:
                        _selectedOption == 'Spam or Misinformation'
                            ? WidgetStatePropertyAll(
                              Theme.of(context).colorScheme.primary,
                            )
                            : WidgetStatePropertyAll(
                              Theme.of(context).colorScheme.tertiary,
                            ),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedOption = value!;
                      });
                    },
                  ),
                  Text(
                    'Spam or Misinformation',
                    style: _reportOptionTextStyle(),
                  ),
                ],
              ),
              Row(
                children: [
                  Radio(
                    value: 'Hate Speech or Violence',
                    groupValue: _selectedOption,
                    fillColor:
                        _selectedOption == 'Hate Speech or Violence'
                            ? WidgetStatePropertyAll(
                              Theme.of(context).colorScheme.primary,
                            )
                            : WidgetStatePropertyAll(
                              Theme.of(context).colorScheme.tertiary,
                            ),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedOption = value!;
                      });
                    },
                  ),
                  Text(
                    'Hate Speech or Violence',
                    style: _reportOptionTextStyle(),
                  ),
                ],
              ),
              Row(
                children: [
                  Radio(
                    value: 'Threats or Harassment',
                    groupValue: _selectedOption,
                    fillColor:
                        _selectedOption == 'Threats or Harassment'
                            ? WidgetStatePropertyAll(
                              Theme.of(context).colorScheme.primary,
                            )
                            : WidgetStatePropertyAll(
                              Theme.of(context).colorScheme.tertiary,
                            ),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedOption = value!;
                      });
                    },
                  ),
                  Text(
                    'Threats or Harassment',
                    style: _reportOptionTextStyle(),
                  ),
                ],
              ),
              Row(
                children: [
                  Radio(
                    value: 'Others',
                    groupValue: _selectedOption,
                    fillColor:
                        _selectedOption == 'Others'
                            ? WidgetStatePropertyAll(
                              Theme.of(context).colorScheme.primary,
                            )
                            : WidgetStatePropertyAll(
                              Theme.of(context).colorScheme.tertiary,
                            ),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedOption = value!;
                      });
                    },
                  ),
                  Text('Others', style: _reportOptionTextStyle()),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            onChanged: (value) {
              setState(() {
                charCount = value.length;
              });
            },
            decoration: InputDecoration(
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.error,
                  width: 21,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
              hintText: 'Give a brief description ...',
              hintStyle: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.tertiary.withValues(alpha: .6),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.tertiary.withValues(alpha: .6),
                  width: 1,
                ),
              ),
              border: OutlineInputBorder(
                gapPadding: 4,
                borderSide: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.tertiary.withValues(alpha: .6),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.tertiary.withValues(alpha: .6),
                  width: 1,
                ),
              ),
            ),
            maxLines: 3,
            minLines: 3,
            style: TextStyle(
              color: Theme.of(context).colorScheme.tertiary,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 18),
          Text(
            '$charCount / 256',
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.tertiary.withValues(alpha: .6),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.tertiary.withValues(alpha: .8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Submit',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.tertiary.withValues(alpha: .8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
