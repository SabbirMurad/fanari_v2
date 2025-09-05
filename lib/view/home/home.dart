import 'package:fanari_v2/model/mention.dart';
import 'package:fanari_v2/model/post.dart';
import 'package:fanari_v2/model/user.dart';
import 'package:fanari_v2/view/home/widgets/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PostModel dummyPost = PostModel(
    uuid: 'asdf3434asd',
    caption:
        'simply dummy text of the printing and typesetting industry. Sabbir Hassan has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. http://pokiee.com It has survived not only five centuries, but also the leap into electronic typesetting, remaining www.fukku.com essentially unchanged. https://youtube.com It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.',
    bookmarked: false,
    mentions: [
      MentionModel(
        user_id: '01',
        username: 'sabbir',
        start_index: 60,
        end_index: 73,
      ),
    ],
    images: [],
    videos: [],
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
    comment_count: 2000,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SafeArea(
              child: Text(
                'This is a dummy test',
                style: TextStyle(color: Colors.red),
              ),
            ),
            PostWidget(model: dummyPost),
          ],
        ),
      ),
    );
  }
}
