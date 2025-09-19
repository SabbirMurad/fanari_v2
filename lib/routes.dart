import 'package:fanari_v2/view/auth/sign_in.dart';
import 'package:fanari_v2/view/auth/sign_up.dart';
import 'package:fanari_v2/view/chat/chat_screen.dart';
import 'package:fanari_v2/view/chat/chat_texts.dart';
import 'package:fanari_v2/view/home_navigator.dart';
import 'package:fanari_v2/view/landing.dart';
import 'package:fanari_v2/view/settings/notification_setting.dart';
import 'package:fanari_v2/view/settings/profile_settings.dart';
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

  //Market
  static final String market = '/market';

  static final String chats = '/chats';
  static final String chatTexts = '/chat';

  //Settings
  static final String settings = '/settings';
  static final String profileSettings = '/profile-settings';
  static final String notificationSettings = '/notification-settings';

  static void push(String route) => allRoutes.push(route);
  static void go(String route) => allRoutes.go(route);
  static void pop() => allRoutes.pop();

  static final allRoutes = GoRouter(
    routes: [
      //! Landing
      GoRoute(
        path: landing,
        builder: (context, state) {
          // return const LandingScreen();
          return const HomeNavigator(selectedPage: 0);
        },
      ),
      //! Auth
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
      //! Home
      GoRoute(
        path: feed,
        // redirect: (context, state) async {
        //   return !(await isSingedIn()) ? sign_in : null;
        // },
        builder: (context, state) {
          return const HomeNavigator(selectedPage: 0);
        },
      ),
      //! Market
      GoRoute(
        path: market,
        // redirect: (context, state) async {
        //   return !(await isSingedIn()) ? sign_in : null;
        // },
        builder: (context, state) {
          return const HomeNavigator(selectedPage: 2);
        },
      ),
      GoRoute(
        path: chats,
        // redirect: (context, state) async {
        //   return !(await isSingedIn()) ? sign_in : null;
        // },
        builder: (context, state) {
          return const ChatScreen();
        },
      ),
      GoRoute(
        path: '$chatTexts/:conversation-id',
        // redirect: (context, state) async {
        //   return !(await isSingedIn()) ? sign_in : null;
        // },
        builder: (context, state) {
          final id = state.pathParameters['conversation-id']!;

          return ChatTextsScreen(conversationId: id);
        },
      ),

      //! Settings
      GoRoute(
        path: settings,
        // redirect: (context, state) async {
        //   return !(await isSingedIn()) ? sign_in : null;
        // },
        builder: (context, state) {
          return const HomeNavigator(selectedPage: 3);
        },
      ),
      GoRoute(
        path: profileSettings,
        // redirect: (context, state) async {
        //   return !(await isSingedIn()) ? sign_in : null;
        // },
        builder: (context, state) {
          return const ProfileSettingScreen();
        },
      ),
      GoRoute(
        path: notificationSettings,
        // redirect: (context, state) async {
        //   return !(await isSingedIn()) ? sign_in : null;
        // },
        builder: (context, state) {
          return const NotificationSettingScreen();
        },
      ),
    ],
  );
}
