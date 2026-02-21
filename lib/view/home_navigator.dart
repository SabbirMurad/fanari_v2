import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/constants/local_storage.dart';
import 'package:fanari_v2/providers/author.dart';
import 'package:fanari_v2/socket.dart';
import 'package:fanari_v2/view/home/home.dart';
import 'package:fanari_v2/view/market/market.dart';
import 'package:fanari_v2/view/search/search.dart';
import 'package:fanari_v2/view/settings/settings.dart';
import 'package:fanari_v2/widgets/bottom_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeNavigator extends ConsumerStatefulWidget {
  final int selectedPage;
  const HomeNavigator({super.key, required this.selectedPage});

  @override
  ConsumerState<HomeNavigator> createState() => _HomeNavigatorState();
}

class _HomeNavigatorState extends ConsumerState<HomeNavigator> {
  late int _selectedTab = widget.selectedPage;
  late PageController _pageController = PageController(
    initialPage: _selectedTab,
  );

  List<Widget> _pages = [
    HomeScreen(),
    SearchScreen(),
    MarketScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();

    _loadUserAndConnectSocket();
  }

  void _loadUserAndConnectSocket() async {
    final access_token = await LocalStorage.access_token.get();

    CustomSocket.instance.connect(ref, access_token: access_token!);
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
            CustomBottomNavigator(
              selectedNavIndex: _selectedTab,
              onNavChange: (index) async {
                _pageController.jumpToPage(index);

                setState(() {
                  _selectedTab = index;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
