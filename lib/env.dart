import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvHandler {
  // String google_map_api_key;
  String youtube_api_key;
  static EnvHandler? _instance;

  EnvHandler({
    // required this.google_map_api_key,
    required this.youtube_api_key,
  });

  static EnvHandler load() {
    _instance ??= EnvHandler(
      // google_map_api_key: dotenv.env['GOOGLE_MAPS_API_KEY']!,
      youtube_api_key: dotenv.env['YOUTUBE_API_KEY']!,
    );

    return _instance!;
  }
}
