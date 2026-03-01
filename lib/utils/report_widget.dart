part of '../utils.dart';

// ── Bottom-sheet launcher ─────────────────────────────────────────────────────

void show_report_widget({required BuildContext context}) {
  showModalBottomSheet(
    backgroundColor: Colors.transparent,
    context: context,
    isScrollControlled: true,
    elevation: 0,
    builder: (_) => GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.transparent,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: const ReportWidget(),
          ),
        ),
      ),
    ),
  );
}

// ── Report options ────────────────────────────────────────────────────────────

const _report_options = [
  'Spam or Misinformation',
  'Hate Speech or Violence',
  'Threats or Harassment',
  'Others',
];

// ── Widget ────────────────────────────────────────────────────────────────────

class ReportWidget extends StatefulWidget {
  const ReportWidget({super.key});

  @override
  State<ReportWidget> createState() => _ReportWidgetState();
}

class _ReportWidgetState extends State<ReportWidget> {
  final _controller = TextEditingController();
  String? _selected_option;
  int _char_count = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  TextStyle get _option_style => TextStyle(
        color: Theme.of(context).colorScheme.tertiary,
        fontSize: 14,
      );

  @override
  Widget build(BuildContext context) {
    final tertiary = Theme.of(context).colorScheme.tertiary;
    final primary = Theme.of(context).colorScheme.primary;

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
              color: tertiary,
              fontSize: 21,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ..._report_options.map(
            (option) => Row(
              children: [
                Radio<String>(
                  value: option,
                  groupValue: _selected_option,
                  fillColor: WidgetStatePropertyAll(
                    _selected_option == option ? primary : tertiary,
                  ),
                  onChanged: (value) =>
                      setState(() => _selected_option = value),
                ),
                Text(option, style: _option_style),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            onChanged: (value) =>
                setState(() => _char_count = value.length),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
              hintText: 'Give a brief description ...',
              hintStyle: TextStyle(color: tertiary.withValues(alpha: .6)),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: tertiary.withValues(alpha: .6)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: tertiary.withValues(alpha: .6)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: tertiary.withValues(alpha: .6)),
              ),
            ),
            maxLines: 3,
            minLines: 3,
            style: TextStyle(color: tertiary, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text(
            '$_char_count / 256',
            style: TextStyle(
              color: tertiary.withValues(alpha: .6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _text_button('Cancel', on_tap: () => Navigator.of(context).pop()),
              const SizedBox(width: 6),
              _text_button('Submit', on_tap: () => Navigator.of(context).pop()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _text_button(String label, {required VoidCallback on_tap}) {
    return TextButton(
      onPressed: on_tap,
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.tertiary.withValues(alpha: .8),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
