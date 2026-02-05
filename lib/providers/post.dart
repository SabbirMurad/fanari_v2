import 'package:fanari_v2/model/mention.dart';
import 'package:fanari_v2/model/post.dart';
import 'package:fanari_v2/providers/user.dart';
import 'package:fanari_v2/utils.dart' as utils;
import 'package:fanari_v2/utils/print_helper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'post.g.dart';

@Riverpod(keepAlive: true)
class PostNotifier extends _$PostNotifier {
  int offset = 1;
  int limit = 10;
  bool showingFromCache = false;

  @override
  FutureOr<List<PostModel>> build() async {
    return await initialLoad() ?? [];
  }

  Future<List<PostModel>?> initialLoad() async {
    // if (!await utils.hasInternet()) {
    //   showingFromCache = true;
    //   return await getPostFromCache();
    // }

    return await getPostFromServer();
  }

  Future<List<PostModel>?> getPostFromServer() async {
    final response = await utils.CustomHttp.get(
      endpoint: '/post',
      queries: {'page': offset, 'limit': limit},
    );

    if (!response.ok) {
      printLine(response.error);
      return null;
    }

    final posts = await PostModel.fromJsonList(response.data);

    final post_owners_ids = posts.map((post) => post.core.owner_id).toList();

    final users = await ref
        .read(userNotifierProvider.notifier)
        .loadMoreUsers(post_owners_ids);

    if (users == null) {
      printLine('Failed to load users');
      return null;
    }

    posts.forEach(
      (post) => post.owner = users.firstWhere(
        (user) => user.core.uuid == post.core.owner_id,
      ),
    );

    //! This is done so that posts loads quickly and info that might take time to load doesn't block the UI
    Future.microtask(() async {
      // Create a mutable copy
      final updated = [...posts];

      for (int i = 0; i < updated.length; i++) {
        await updated[i].core.load3rdPartyInfos();
      }

      // After all posts finished updating, update provider state
      state = AsyncData(updated);
    });

    return posts;
  }

  Future<void> createPost({
    String? page_id,
    String? caption,
    required List<String> images,
    required List<String> videos,
    String? audio,
    required List<MentionModel> mentions,
    required List<String> tags,
    bool is_nsfw = false,
    String? content_warning,
    required String visibility,
    dynamic poll,
  }) async {
    final response = await utils.CustomHttp.post(
      endpoint: '/post',
      body: {
        'page_id': page_id,
        'caption': caption,
        'images': images,
        'videos': videos,
        'audio': audio,
        'mentions': mentions,
        'is_nsfw': is_nsfw,
        'content_warning': content_warning,
        'visibility': visibility,
        'tags': tags,
        'poll': poll,
      },
    );

    if (!response.ok) return;

    final new_post = PostModel.fromJson(response.data);

    final users = await ref.read(userNotifierProvider.notifier).loadMoreUsers([
      new_post.core.owner_id,
    ]);

    if (users == null) {
      printLine('Failed to load users');
      return null;
    }

    new_post.owner = users.firstWhere(
      (user) => user.core.uuid == new_post.core.owner_id,
    );

    state = AsyncData([new_post, ...state.value!]);
  }
}
