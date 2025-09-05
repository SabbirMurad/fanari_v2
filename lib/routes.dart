import 'package:fanari_v2/view/auth/sign_in.dart';
import 'package:fanari_v2/view/auth/sign_up.dart';
import 'package:fanari_v2/view/home_navigator.dart';
import 'package:fanari_v2/view/landing.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> isSingedIn() async {
  SharedPreferences localStorage = await SharedPreferences.getInstance();
  String? accessToken = localStorage.getString('access_token');

  if (accessToken != null) {
    return true;
  } else {
    return false;
  }
}

class AppRoutes {
  AppRoutes._();

  static final String landing = '/';
  static final String sign_up = '/sign-up';
  static final String sign_in = '/sign-in';

  static final String feed = '/feed';

  static void push(String route) => allRoutes.push(route);
  static void go(String route) => allRoutes.go(route);

  static final allRoutes = GoRouter(
    routes: [
      GoRoute(
        path: landing,
        builder: (context, state) {
          return const LandingScreen();
          // return const HomeNavigator(selectedPage: 0);
        },
      ),
      GoRoute(
        path: sign_up,
        redirect: (context, state) async {
          return await isSingedIn() ? feed : null;
        },
        builder: (context, state) {
          return const SignUpScreen();
        },
      ),
      GoRoute(
        path: sign_in,
        redirect: (context, state) async {
          return await isSingedIn() ? feed : null;
        },
        builder: (context, state) {
          return const SignInScreen();
        },
      ),
      GoRoute(
        path: feed,
        // redirect: (context, state) async {
        //   return !(await isSingedIn()) ? sign_in : null;
        // },
        builder: (context, state) {
          return const HomeNavigator(selectedPage: 0);
        },
      ),
      // GoRoute(
      //   path: "/home/:tab",
      //   redirect: (context, state) async {
      //     return await isSingedIn() ? null : '/authentication';
      //   },
      //   builder: (context, state) {
      //     final List<String> tabs = [
      //       "home",
      //       "search",
      //       "notification",
      //     ];

      //     final tab = state.pathParameters['tab']!;
      //     int selectedPage = 0;
      //     if (tabs.contains(tab)) {
      //       selectedPage = tabs.indexOf(tab);
      //     }

      //     return HomePage(
      //       selectedPage: selectedPage,
      //     );
      //   },
      // ),
      // GoRoute(
      //   path: "/profile/:myProfile/:userId",
      //   redirect: (context, state) async {
      //     return await isSingedIn() ? null : '/authentication';
      //   },
      //   builder: (context, state) {
      //     final myProfile = state.pathParameters['myProfile']!;
      //     final bool isMyProfile = myProfile == 'true';
      //     return ProfilePage(
      //       myProfile: isMyProfile,
      //       userId: state.pathParameters['userId']!,
      //     );
      //   },
      // ),
      // GoRoute(
      //   path: "/setting",
      //   redirect: (context, state) async {
      //     return await isSingedIn() ? null : '/authentication';
      //   },
      //   builder: (context, state) {
      //     return const SettingPage();
      //   },
      // ),
      // GoRoute(
      //   path: "/post/:postId",
      //   redirect: (context, state) async {
      //     return await isSingedIn() ? null : '/authentication';
      //   },
      //   builder: (context, state) {
      //     return PostDetailsPage(
      //       postId: state.pathParameters['postId']!,
      //     );
      //   },
      // ),
    ],
  );
}
