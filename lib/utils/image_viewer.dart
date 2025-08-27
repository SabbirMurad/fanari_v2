part of '../utils.dart';

class GalleryImageViewer extends StatefulWidget {
  final List<ImageProvider> images;
  final int index;
  final PageController pageController;
  final bool showNumber;
  final int? preLoad;

  GalleryImageViewer({
    super.key,
    required this.images,
    required this.index,
    this.showNumber = false,
    this.preLoad,
  }) : pageController = PageController(initialPage: index);

  @override
  State<GalleryImageViewer> createState() => _GalleryImageViewerState();
}

class _GalleryImageViewerState extends State<GalleryImageViewer> {
  late int _index = widget.index;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(56, 53, 66, 1),
      body: Stack(
        alignment: Alignment.topRight,
        children: [
          PhotoViewGallery.builder(
            pageController: widget.pageController,
            scrollDirection: Axis.horizontal,
            itemCount: widget.images.length,
            pageSnapping: true,
            loadingBuilder: (context, event) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: Color.fromRGBO(24, 24, 24, 1),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
            onPageChanged: (index) {
              setState(() {
                _index = index;
              });
            },
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: widget.images[index],
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.contained * 4,
              );
            },
          ),
          if (widget.showNumber)
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: EdgeInsets.only(top: 24, right: 12),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(24, 24, 24, .8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_index + 1}/${widget.images.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (widget.preLoad != null)
                    Opacity(
                      opacity: 0,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (int i = _index + 1;
                                i < widget.images.length &&
                                    i < _index + 1 + widget.preLoad!;
                                i++)
                              Container(
                                width: 5,
                                height: 5,
                                color: Colors.pink,
                                margin: const EdgeInsets.only(right: 8),
                                child: Image(
                                  image: widget.images[i],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            )
        ],
      ),
    );
  }
}

void openImageViewer({
  required BuildContext context,
  required List<ImageProvider> images,
  int index = 0,
  bool showNumber = false,
  int? preLoad,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) {
        return GalleryImageViewer(
          images: images,
          index: index,
          showNumber: showNumber,
          preLoad: preLoad,
        );
      },
    ),
  );
}
