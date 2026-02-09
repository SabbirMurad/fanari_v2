import 'package:fanari_v2/constants/local_storage.dart';
import 'package:fanari_v2/view/auth/sign_in.dart';
import 'package:fanari_v2/view/auth/sign_up.dart';
import 'package:fanari_v2/view/chat/chat_screen.dart';
import 'package:fanari_v2/view/home_navigator.dart';
import 'package:fanari_v2/view/landing.dart';
import 'package:fanari_v2/view/profile/profile.dart';
import 'package:fanari_v2/view/settings/notification_setting.dart';
import 'package:fanari_v2/view/settings/profile_settings.dart';
import 'package:go_router/go_router.dart';

Future<bool> isSingedIn() async {
  String? accessToken = await LocalStorage.access_token.get();

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

  //Profile
  static final String profile = '/profile/:userId';

  static void push(String route) => allRoutes.push(route);
  static void go(String route) => allRoutes.go(route);
  static void pop() {
    if (allRoutes.canPop()) {
      allRoutes.pop();
    } else {
      allRoutes.go(landing);
    }
  }

  static final allRoutes = GoRouter(
    routes: [
      //! Landing
      GoRoute(
        path: landing,
        builder: (context, state) {
          return const LandingScreen();
          // return const HomeNavigator(selectedPage: 0);
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
        path: profile,
        // redirect: (context, state) async {
        //   return !(await isSingedIn()) ? sign_in : null;
        // },
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return ProfileScreen(user_id: userId);
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
      // GoRoute(
      //   path: '$chatTexts/:conversation-id',
      //   // redirect: (context, state) async {
      //   //   return !(await isSingedIn()) ? sign_in : null;
      //   // },
      //   builder: (context, state) {
      //     final id = state.pathParameters['conversation-id']!;

      //     return ChatTextsScreen(conversationId: id);
      //   },
      // ),

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
