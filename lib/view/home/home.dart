import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/model/image.dart';
import 'package:fanari_v2/model/mention.dart';
import 'package:fanari_v2/model/poll.dart';
import 'package:fanari_v2/model/post.dart';
import 'package:fanari_v2/model/user.dart';
import 'package:fanari_v2/view/home/widgets/post.dart';
import 'package:fanari_v2/widgets/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

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

    _loadPostExtras();
  }

  void _loadPostExtras() async {
    for (final item in _dummyPosts) {
      await item.load3rdPartyInfos();
    }

    setState(() {});
  }

  List<PostModel> _dummyPosts = [
    PostModel(
      uuid: 'asdf3434asd',
      caption: 'This is an example of a poll inside a post',
      bookmarked: false,
      mentions: [],
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
      poll: PollModel(
        question: 'Who is the strongest anime protagonist of all time?',
        type: PollType.single,
        can_add_option: false,
        selected_options: [],
        options: [
          PollOption(text: 'Sun Goku', vote: 20),
          PollOption(text: 'Gojo Satoru', vote: 25),
          PollOption(text: 'Madara Uchiha', vote: 50),
          PollOption(text: 'Sabbir Hassan', vote: 10),
        ],
        total_vote: 105,
      ),
      liked: false,
      like_count: 1500000,
      comment_count: 2000,
    ),
    PostModel(
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
    ),
    PostModel(
      uuid: 'asdasdf3434asasdd',
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
    ),
    PostModel(
      uuid: 'asdf3asd434asd',
      caption: 'link preview https://instagram.com',
      bookmarked: false,
      mentions: [],
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
    ),
    PostModel(
      uuid: 'asdf3434aasdwsd',
      caption:
          'here is a preview for youtube attachment https://www.youtube.com/watch?v=bc7JKgki3l0',
      bookmarked: false,
      mentions: [],
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
    ),
  ];

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

  Future<void> _onRefresh() async {
    setState(() {
      _refreshing = true;
    });
    // await ref.read(postsNotifierProvider.notifier).refresh();
    //TODO: change wait time back to 300ms
    Future.delayed(const Duration(milliseconds: 4000), () {
      setState(() {
        _refreshing = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LiquidPullToRefresh(
      onRefresh: _onRefresh,
      height: 172,
      showChildOpacityTransition: false,
      animSpeedFactor: 2.0,
      color: AppColors.surface,
      backgroundColor: AppColors.secondary,
      child: SizedBox(
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
                return PostWidget(model: _dummyPosts[index]);
              }, childCount: _dummyPosts.length),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 96.h)),
          ],
        ),
      ),
    );
  }
}
