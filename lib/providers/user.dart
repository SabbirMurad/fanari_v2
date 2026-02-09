import 'package:fanari_v2/model/user.dart';
import 'package:fanari_v2/utils.dart' as utils;
import 'package:fanari_v2/utils/print_helper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user.g.dart';

@Riverpod(keepAlive: true)
class UserNotifier extends _$UserNotifier {
  List<String> loaded_user_ids = [];

  @override
  FutureOr<List<UserModel>> build() async {
    return [];
  }

  Future<List<UserModel>?> loadMoreUsers(List<String> user_ids) async {
    List<String> users_to_load = [];

    for (final user_id in user_ids) {
      if (!loaded_user_ids.contains(user_id)) {
        users_to_load.add(user_id);
      }
    }

    if (users_to_load.isEmpty) return state.value;

    final response = await utils.CustomHttp.post(
      endpoint: '/profile/list',
      body: user_ids,
    );

    if (!response.ok) {
      printLine(response.error);
      return null;
    }

    final users = UserModel.fromJsonList(response.data);

    users.forEach((user) => loaded_user_ids.add(user.core.uuid));

    state = AsyncValue.data(state.value! + users);

    return state.value;
  }

  Future<UserModel?> loadSingleUsers(String user_id) async {
    if (loaded_user_ids.contains(user_id)) {
      return state.value!.firstWhere((user) => user.core.uuid == user_id);
    }

    final response = await utils.CustomHttp.post(
      endpoint: '/profile/list',
      body: [user_id],
    );

    if (!response.ok) {
      printLine(response.error);
      return null;
    }

    final users = UserModel.fromJsonList(response.data);

    users.forEach((user) => loaded_user_ids.add(user.core.uuid));

    state = AsyncValue.data(state.value! + users);

    return state.value!.firstWhere((user) => user.core.uuid == user_id);
  }
}
