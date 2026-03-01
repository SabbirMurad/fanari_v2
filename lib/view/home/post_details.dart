import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/model/comment.dart';
import 'package:fanari_v2/model/post.dart';
import 'package:fanari_v2/view/home/widgets/comment.dart';
import 'package:fanari_v2/view/home/widgets/comment_input.dart';
import 'package:fanari_v2/view/home/widgets/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PostDetailsScreen extends StatefulWidget {
  final PostModel model;

  const PostDetailsScreen({super.key, required this.model});

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  List<CommentModel> _comments = [];

  @override
  void initState() {
    super.initState();

    _loadPostExtras();
  }

  void _loadPostExtras() async {
    for (final item in _comments) {
      await item.load_third_party_infos();
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.surface,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SafeArea(bottom: false, child: SizedBox(height: 12.h)),
                    PostWidget(model: widget.model, detailsPage: true),
                    ..._comments.asMap().entries.map((entry) {
                      final comment = entry.value;
                      // final index = entry.key;
                      return CommentWidget(model: comment);
                    }).toList(),
                    SizedBox(height: 72.h),
                  ],
                ),
              ),
            ),
            CommentInputWidget(),
          ],
        ),
      ),
    );
  }
}
