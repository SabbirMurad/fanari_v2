import 'package:fanari_v2/model/emoji.dart';
import 'package:fanari_v2/utils.dart' as utils;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'emoji.g.dart';

@Riverpod(keepAlive: true)
class EmojiNotifier extends _$EmojiNotifier {
  int offset = 1;
  int limit = 10;
  bool showingFromCache = false;

  @override
  FutureOr<List<EmojiModel>> build() async {
    return await initialLoad() ?? [];
  }

  Future<List<EmojiModel>?> initialLoad() async {
    // if (!await utils.hasInternet()) {
    //   showingFromCache = true;
    //   return await getPostFromCache();
    // }

    return await getPostFromServer();
  }

  Future<List<EmojiModel>?> getPostFromServer() async {
    final response = await utils.CustomHttp.get(
      endpoint: '/emoji/list',
      // queries: {'page': offset, 'limit': limit},
    );

    if (!response.ok) return null;

    final posts = EmojiModel.fromJsonList(response.data);

    return posts;
  }
}
