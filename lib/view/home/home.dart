import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/model/mention.dart';
import 'package:fanari_v2/model/post.dart';
import 'package:fanari_v2/model/user.dart';
import 'package:fanari_v2/view/home/widgets/post.dart';
import 'package:fanari_v2/widgets/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ScrollController _scrollController = ScrollController();
  bool _loadingMore = false;
  bool _crossedBottomBar = false;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      // if (_scrollController.offset >
      //     _scrollController.position.maxScrollExtent * 0.8) {
      //   if (_crossedBottomBar) return;
      //   _crossedBottomBar = true;

      //   setState(() {
      //     _loadingMore = true;
      //   });
      //   //TODO: stop calling when reached the bottom of all post
      //   ref.read(postsNotifierProvider.notifier).loadMore();
      //   setState(() {
      //     _loadingMore = false;
      //   });
      // } else {
      //   _crossedBottomBar = false;
      // }
    });
  }

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

  Widget _appBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          CustomSvg(
            'assets/icons/logo.svg',
            color: AppColors.primary,
            height: 28.h,
          ),
          SizedBox(width: 12.w),
          Text(
            'Fanari',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 19.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          Spacer(),
          CustomSvg(
            'assets/icons/notification.svg',
            color: AppColors.text,
            height: 24.w,
          ),
          SizedBox(width: 18.w),
          CustomSvg(
            'assets/icons/chat.svg',
            color: AppColors.text,
            height: 24.w,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: CustomScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            titleSpacing: 0.0,
            title: _appBar(),
            floating: true,
            snap: true,
            automaticallyImplyLeading: false,
            actions: [Container()],
            expandedHeight: 30.h,
            surfaceTintColor: AppColors.surface,
            backgroundColor: AppColors.surface,
            shadowColor: AppColors.containerBg,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return PostWidget(model: dummyPost);
            }, childCount: 20),
          ),
          // PostWidget(model: dummyPost),
        ],
      ),
    );
  }
}
