import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/widgets/cross_fade_box.dart';
import 'package:fanari_v2/widgets/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  ScrollController _scrollController = ScrollController();
  bool _loadingMore = false;
  bool _crossedBottomBar = false;
  bool _refreshing = false;

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

  List<String> _categories = [
    'Action Figure',
    'Body Pillow',
    'Cosplay Items',
    'Custom Weapons',
    'T Shirts',
  ];

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
            SliverToBoxAdapter(child: SizedBox(height: 24.h)),
            SliverToBoxAdapter(
              child: ColorFadeBox(
                width: double.infinity,
                height: 208.h,
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 36.h)),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 20.w),
                    ..._categories.map((item) {
                      return Container(
                        width: 56.w,
                        margin: EdgeInsets.only(right: 32.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ColorFadeBox(
                              width: 56.w,
                              height: 56.w,
                              borderRadius: BorderRadius.circular(28.r),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              item,
                              style: TextStyle(
                                color: AppColors.text,
                                fontSize: 11.sp,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 36.h)),
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    Text(
                      'Trending',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Spacer(),
                    Text(
                      'Show More',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 24.h)),
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                child: Wrap(
                  spacing: 18.w,
                  runSpacing: 18.w,
                  children: List.generate(6, (index) {
                    return Column(
                      children: [
                        ColorFadeBox(
                          width: (1.sw - 40.w - 18.w) / 2,
                          height: (1.sw - 40.w - 18.w) / 2,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 96.h)),
          ],
        ),
      ),
    );
  }
}
