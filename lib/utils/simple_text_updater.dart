part of '../utils.dart';

// ── Bottom-sheet launcher ─────────────────────────────────────────────────────

void show_simple_text_updater({
  required BuildContext context,
  required String title,
  String? previous_text,
  int? max_chars,
  int? min_chars,
  required ValueChanged<String> on_update,
}) {
  showModalBottomSheet(
    backgroundColor:
        Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
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
            child: SimpleTextUpdater(
              title: title,
              previous_text: previous_text,
              max_chars: max_chars,
              min_chars: min_chars,
              on_update: on_update,
            ),
          ),
        ),
      ),
    ),
  );
}

// ── Widget ────────────────────────────────────────────────────────────────────

class SimpleTextUpdater extends StatefulWidget {
  final String title;
  final String? previous_text;
  final int? max_chars;
  final int? min_chars;
  final ValueChanged<String> on_update;

  const SimpleTextUpdater({
    super.key,
    required this.title,
    this.previous_text,
    this.max_chars,
    this.min_chars,
    required this.on_update,
  });

  @override
  State<SimpleTextUpdater> createState() => _SimpleTextUpdaterState();
}

class _SimpleTextUpdaterState extends State<SimpleTextUpdater> {
  final _controller = TextEditingController();
  int _char_count = 0;

  bool get _is_below_min =>
      widget.min_chars != null && _char_count < widget.min_chars!;
  bool get _is_above_max =>
      widget.max_chars != null && _char_count > widget.max_chars!;
  bool get _is_valid => !_is_below_min && !_is_above_max;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.previous_text ?? '';
    _char_count = _controller.text.length;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  TextStyle _limit_text_style(bool is_error) => TextStyle(
        color: is_error
            ? Colors.red[400]
            : Theme.of(context).colorScheme.tertiary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );

  @override
  Widget build(BuildContext context) {
    final tertiary = Theme.of(context).colorScheme.tertiary;

    return Container(
      width: 1.sw - 24,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              color: tertiary,
              fontSize: 21,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _controller,
            onChanged: (value) => setState(() => _char_count = value.length),
            decoration: const InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
            ),
            maxLines: null,
            minLines: 1,
            style: TextStyle(color: tertiary, fontSize: 15),
          ),
          Container(
            width: double.infinity,
            height: 1,
            color: Theme.of(context).colorScheme.secondary,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
            child: Row(
              children: [
                if (widget.min_chars != null)
                  Text(
                    'Min: $_char_count / ${widget.min_chars}',
                    style: _limit_text_style(_is_below_min),
                  ),
                const Spacer(),
                if (widget.max_chars != null)
                  Text(
                    'Max: $_char_count / ${widget.max_chars}',
                    style: _limit_text_style(_is_above_max),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: tertiary.withValues(alpha: .8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              TextButton(
                onPressed: _is_valid
                    ? () {
                        widget.on_update(_controller.text);
                        Navigator.of(context).pop();
                      }
                    : null,
                child: Text(
                  'Update',
                  style: TextStyle(
                    color: _is_valid
                        ? tertiary.withValues(alpha: .8)
                        : tertiary.withValues(alpha: .3),
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
