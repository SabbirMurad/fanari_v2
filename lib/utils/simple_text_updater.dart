part of '../utils.dart';

void showSimpleTextUpdater({
  required BuildContext context,
  required String title,
  String? previousText,
  int? maxChar,
  int? minChar,
  required Function(String) onUpdate,
}) {
  showModalBottomSheet(
    backgroundColor: Theme.of(
      context,
    ).colorScheme.tertiary.withValues(alpha: 0.1),
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
              child: SimpleTextUpdater(
                title: title,
                previousText: previousText,
                maxChar: maxChar,
                minChar: minChar,
                onUpdate: onUpdate,
              ),
            ),
          ),
        ),
      );
    },
  );
}

class SimpleTextUpdater extends StatefulWidget {
  final String title;
  final String? previousText;
  final int? maxChar;
  final int? minChar;
  final Function(String) onUpdate;

  const SimpleTextUpdater({
    super.key,
    required this.title,
    this.previousText,
    this.maxChar,
    this.minChar,
    required this.onUpdate,
  });

  @override
  State<SimpleTextUpdater> createState() => _SimpleTextUpdaterState();
}

class _SimpleTextUpdaterState extends State<SimpleTextUpdater> {
  TextStyle _maxMinTextStyle(type) {
    return TextStyle(
      color:
          type == 'ok'
              ? Theme.of(context).colorScheme.tertiary
              : Colors.red[400],
      fontSize: 14,
      fontWeight: FontWeight.w400,
    );
  }

  final TextEditingController _controller = TextEditingController();
  int charCount = 0;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.previousText ?? '';
    setState(() {
      charCount = _controller.text.length;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              color: Theme.of(context).colorScheme.tertiary,
              fontSize: 21,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _controller,
            onChanged: (value) {
              setState(() {
                charCount = value.length;
              });
            },
            decoration: const InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
            ),
            maxLines: null,
            minLines: 1,
            style: TextStyle(
              color: Theme.of(context).colorScheme.tertiary,
              fontSize: 15,
            ),
          ),
          Container(
            width: double.infinity,
            height: 1,
            color: Theme.of(context).colorScheme.secondary,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                if (widget.minChar != null)
                  Text(
                    'Min: $charCount / ${widget.minChar}',
                    style: _maxMinTextStyle(
                      charCount < widget.minChar! ? 'error' : 'ok',
                    ),
                  ),
                const Spacer(),
                if (widget.maxChar != null)
                  Text(
                    'Max: $charCount / ${widget.maxChar}',
                    style: _maxMinTextStyle(
                      charCount > widget.maxChar! ? 'error' : 'ok',
                    ),
                  ),
              ],
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
                  if (widget.maxChar != null && charCount > widget.maxChar!) {
                    return;
                  }

                  if (widget.minChar != null && charCount < widget.minChar!) {
                    return;
                  }

                  widget.onUpdate(_controller.text);
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Update',
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
