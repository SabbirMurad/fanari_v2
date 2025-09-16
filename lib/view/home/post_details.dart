import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/model/comment.dart';
import 'package:fanari_v2/model/image.dart';
import 'package:fanari_v2/model/mention.dart';
import 'package:fanari_v2/model/post.dart';
import 'package:fanari_v2/model/user.dart';
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
  List<CommentModel> _comments = [
    CommentModel(
      uuid: 'asdf3434asd',
      caption:
          'simply dummy text of the printing and typesetting industry. Sabbir Hassan has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. http://pokiee.com It has survived not only five centuries, but also the leap into electronic typesetting, remaining www.fukku.com essentially unchanged. https://youtube.com It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.',
      mentions: [
        MentionModel(
          user_id: '01',
          username: 'sabbir',
          start_index: 60,
          end_index: 73,
        ),
      ],
      images: [],
      created_at: DateTime.now().millisecondsSinceEpoch,
      owner: UserModel(
        name: 'Sabbir Hassan',
        username: 'sabbir0087',
        is_me: false,
        following: false,
        friend: false,
      ),
      liked: false,
      like_count: 1500000,
      reply_count: 2000,
    ),
    CommentModel(
      uuid: 'asdasdf3434asasdd',
      caption:
          'simply dummy text of the printing and typesetting industry. Sabbir Hassan has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. http://pokiee.com It has survived not only five centuries, but also the leap into electronic typesetting, remaining www.fukku.com essentially unchanged. https://youtube.com It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.',
      mentions: [
        MentionModel(
          user_id: '01',
          username: 'sabbir',
          start_index: 60,
          end_index: 73,
        ),
      ],
      images: [
        ImageModel(
          uuid: 'asdasdasd',
          url:
              'https://images.pexels.com/photos/1535051/pexels-photo-1535051.jpeg',
          width: 400,
          height: 400,
          provider: AssetImage('assets/images/temp/user.jpg'),
        ),
        ImageModel(
          uuid: 'asdasdasd',
          url:
              'https://images.pexels.com/photos/341970/pexels-photo-341970.jpeg',
          width: 400,
          height: 400,
          provider: AssetImage('assets/images/temp/user.jpg'),
        ),
        ImageModel(
          uuid: 'asdasdasd',
          url:
              'https://images.pexels.com/photos/1832959/pexels-photo-1832959.jpeg',
          width: 400,
          height: 400,
          provider: AssetImage('assets/images/temp/user.jpg'),
        ),
        ImageModel(
          uuid: 'asdasdasd',
          url:
              'https://images.pexels.com/photos/1468379/pexels-photo-1468379.jpeg',
          width: 400,
          height: 400,
          provider: AssetImage('assets/images/temp/user.jpg'),
        ),
        ImageModel(
          uuid: 'asdasdasd',
          url:
              'https://images.pexels.com/photos/1580271/pexels-photo-1580271.jpeg',
          width: 400,
          height: 400,
          provider: AssetImage('assets/images/temp/user.jpg'),
        ),
      ],
      created_at: DateTime.now().millisecondsSinceEpoch,
      owner: UserModel(
        name: 'Sabbir Hassan',
        username: 'sabbir0087',
        is_me: false,
        following: false,
        friend: false,
      ),
      liked: false,
      like_count: 1500000,
      reply_count: 2000,
    ),
    CommentModel(
      uuid: 'asdf3asd434asd',
      caption: 'link preview https://instagram.com',
      mentions: [],
      images: [],
      created_at: DateTime.now().millisecondsSinceEpoch,
      owner: UserModel(
        name: 'Sabbir Hassan',
        username: 'sabbir0087',
        is_me: false,
        following: false,
        friend: false,
      ),
      liked: false,
      like_count: 1500000,
      reply_count: 2000,
    ),
    CommentModel(
      uuid: 'asdf3434aasdwsd',
      caption:
          'here is a preview for youtube attachment https://www.youtube.com/watch?v=bc7JKgki3l0',
      mentions: [],
      images: [],
      created_at: DateTime.now().millisecondsSinceEpoch,
      owner: UserModel(
        name: 'Sabbir Hassan',
        username: 'sabbir0087',
        is_me: false,
        following: false,
        friend: false,
      ),
      liked: false,
      like_count: 1500000,
      reply_count: 2000,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _loadPostExtras();
  }

  void _loadPostExtras() async {
    for (final item in _comments) {
      await item.load3rdPartyInfos();
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
