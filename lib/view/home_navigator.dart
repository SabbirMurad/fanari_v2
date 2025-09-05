import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/view/home/home.dart';
import 'package:fanari_v2/view/market/market.dart';
import 'package:fanari_v2/view/search/search.dart';
import 'package:fanari_v2/widgets/bottom_navigator.dart';
import 'package:flutter/material.dart';

class HomeNavigator extends StatefulWidget {
  final int selectedPage;
  const HomeNavigator({super.key, required this.selectedPage});

  @override
  State<HomeNavigator> createState() => _HomeNavigatorState();
}

class _HomeNavigatorState extends State<HomeNavigator> {
  late int _selectedTab = widget.selectedPage;
  late PageController _pageController = PageController(
    initialPage: _selectedTab,
  );

  List<Widget> _pages = [HomeScreen(), SearchScreen(), MarketScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.surface,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: PageView(
                  controller: _pageController,
                  pageSnapping: true,
                  onPageChanged: (value) async {
                    setState(() {
                      _selectedTab = value;
                    });
                  },
                  children: _pages,
                ),
              ),
            ),
            // CustomBottomNavigator(
            //   selectedNavIndex: _selectedTab,
            //   onNavChange: (index) async {
            //     _pageController.animateToPage(
            //       index,
            //       duration: Duration(milliseconds: 372),
            //       curve: Curves.easeInOut,
            //     );

            //     setState(() {
            //       _selectedTab = index;
            //     });
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
