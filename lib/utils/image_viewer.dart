part of '../utils.dart';

// ── Gallery viewer widget ─────────────────────────────────────────────────────

class GalleryImageViewer extends StatefulWidget {
  final List<ImageProvider> images;
  final int initial_index;
  final bool show_counter;

  /// How many images ahead of the current one to pre-render (off-screen).
  final int? preload_count;

  final PageController page_controller;

  GalleryImageViewer({
    super.key,
    required this.images,
    this.initial_index = 0,
    this.show_counter = false,
    this.preload_count,
  }) : page_controller = PageController(initialPage: initial_index);

  @override
  State<GalleryImageViewer> createState() => _GalleryImageViewerState();
}

class _GalleryImageViewerState extends State<GalleryImageViewer> {
  late int _current_index = widget.initial_index;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(56, 53, 66, 1),
      body: Stack(
        alignment: Alignment.topRight,
        children: [
          PhotoViewGallery.builder(
            pageController: widget.page_controller,
            scrollDirection: Axis.horizontal,
            itemCount: widget.images.length,
            pageSnapping: true,
            loadingBuilder: (_, __) => const ColoredBox(
              color: Color.fromRGBO(24, 24, 24, 1),
              child: Center(child: CircularProgressIndicator()),
            ),
            onPageChanged: (index) => setState(() => _current_index = index),
            builder: (_, index) => PhotoViewGalleryPageOptions(
              imageProvider: widget.images[index],
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.contained * 4,
            ),
          ),
          if (widget.show_counter) _counter_overlay(),
        ],
      ),
    );
  }

  Widget _counter_overlay() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(top: 24, right: 12),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(24, 24, 24, .8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${_current_index + 1} / ${widget.images.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (widget.preload_count != null)
            Opacity(
              opacity: 0,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (int i = _current_index + 1;
                        i < widget.images.length &&
                            i < _current_index + 1 + widget.preload_count!;
                        i++)
                      SizedBox(
                        width: 5,
                        height: 5,
                        child: Image(image: widget.images[i]),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Public API ────────────────────────────────────────────────────────────────

/// Pushes a full-screen [GalleryImageViewer] onto the navigator stack.
void open_image_viewer({
  required BuildContext context,
  required List<ImageProvider> images,
  int initial_index = 0,
  bool show_counter = false,
  int? preload_count,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => GalleryImageViewer(
        images: images,
        initial_index: initial_index,
        show_counter: show_counter,
        preload_count: preload_count,
      ),
    ),
  );
}
