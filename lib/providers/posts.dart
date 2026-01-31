import 'package:fanari_v2/model/mention.dart';
import 'package:fanari_v2/model/post.dart';
import 'package:fanari_v2/utils.dart' as utils;
import 'package:fanari_v2/utils/print_helper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'posts.g.dart';

@Riverpod(keepAlive: true)
class PostsNotifier extends _$PostsNotifier {
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

    if (response.statusCode != 200) return null;
    
    final posts = PostModel.fromJsonList(response.data);

    //! This is done so that posts loads quickly and info that might take time to load doesn't block the UI
    Future.microtask(() async {
      // Create a mutable copy
      final updated = [...posts];

      for (int i = 0; i < updated.length; i++) {
        await updated[i].load3rdPartyInfos();
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

    if (response.statusCode != 200) return;

    state = AsyncData([PostModel.fromJson(response.data), ...state.value!]);
  }
}
