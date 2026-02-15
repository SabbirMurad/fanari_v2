import 'package:fanari_v2/routes.dart';
import 'package:flutter/material.dart';
import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/providers/post.dart';
import 'package:fanari_v2/widgets/custom_svg.dart';
import 'package:fanari_v2/view/home/widgets/post.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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
            onTap: () {
              AppRoutes.push(AppRoutes.chats);
            },
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
    final posts = ref.watch(postNotifierProvider);

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
            if (!_refreshing)
              SliverList(
                delegate: posts.when(
                  loading: () {
                    return SliverChildBuilderDelegate((context, index) {
                      return Container();
                    }, childCount: 5);
                  },
                  error: (obj, stack) {
                    return SliverChildBuilderDelegate((context, index) {
                      return Container();
                    }, childCount: 1);
                  },
                  data: (posts) {
                    return SliverChildBuilderDelegate((context, index) {
                      final post = posts[index];
                      return PostWidget(key: Key(post.core.uuid), model: post);
                    }, childCount: posts.length);
                  },
                ),
              ),
            if (_loadingMore || _refreshing)
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return Padding(
                    padding: EdgeInsets.only(top: index == 0 ? 36 : 0),
                    child: Container(),
                  );
                }, childCount: 5),
              ),
            SliverToBoxAdapter(child: SizedBox(height: 96.h)),
          ],
        ),
      ),
    );
  }
}
