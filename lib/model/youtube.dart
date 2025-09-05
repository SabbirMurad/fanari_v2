import 'dart:convert';
import 'package:fanari_v2/constants/credential.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class YoutubeModel {
  final String id;
  final String url;
  final YoutubeModelSnippet snippet;
  final YoutubeModelContentDetails contentDetails;
  final YoutubeModelStatistics statistics;

  const YoutubeModel({
    required this.id,
    required this.url,
    required this.snippet,
    required this.contentDetails,
    required this.statistics,
  });

  static String getYoutubeBasicDataUrl(String videoId) =>
      "https://www.googleapis.com/youtube/v3/videos?part=snippet,contentDetails,statistics&fields=items(id,snippet(publishedAt,title,channelTitle,thumbnails(standard)),contentDetails(duration),statistics)&id=$videoId&key=${AppCredentials.youtubeApiKey}";

  static Future<YoutubeModel?> load(attachment_id) async {
    try {
      final url = getYoutubeBasicDataUrl(attachment_id);

      final uri = Uri.parse(url);
      Map<String, String> headers = {'Content-Type': 'application/json'};
      var response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        return YoutubeModel.fromJson(jsonDecode(response.body)['items'][0]);
      } else {
        debugPrint('');
        debugPrint('Error getting youtube attachment data');
        debugPrint('${response.statusCode}');
        debugPrint('');
        return null;
      }
    } catch (e) {
      debugPrint('');
      debugPrint('Error getting youtube attachment data');
      debugPrint(e.toString());
      debugPrint('');
      return null;
    }
  }

  static final _patterns = [
    RegExp(r'(?:https?:\/\/)?(?:www\.)?youtube\.com\/watch\?v=([^&\s]+)'),
    RegExp(r'(?:https?:\/\/)?(?:www\.)?youtu\.be\/([^?\s]+)'),
    RegExp(r'(?:https?:\/\/)?(?:www\.)?youtube\.com\/shorts\/([^?\s]+)'),
  ];

  static String? searchId(String text) {
    for (final pattern in _patterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.groupCount >= 1) {
        return match.group(1);
      }
    }
    return null;
  }

  factory YoutubeModel.fromJson(json) {
    return YoutubeModel(
      id: json['id'],
      url: 'https://www.youtube.com/watch?v=${json['id']}',
      snippet: YoutubeModelSnippet.fromJson(json['snippet']),
      contentDetails: YoutubeModelContentDetails.fromJson(
        json['contentDetails'],
      ),
      statistics: YoutubeModelStatistics.fromJson(json['statistics']),
    );
  }
}

class YoutubeModelSnippet {
  final String publishedAt;
  final String title;
  final String channelTitle;
  final YoutubeModelThumbnails thumbnails;

  const YoutubeModelSnippet({
    required this.publishedAt,
    required this.title,
    required this.channelTitle,
    required this.thumbnails,
  });

  factory YoutubeModelSnippet.fromJson(json) {
    return YoutubeModelSnippet(
      publishedAt: json['publishedAt'],
      title: json['title'],
      channelTitle: json['channelTitle'],
      thumbnails: YoutubeModelThumbnails(
        standard: YoutubeModelThumbnailType(
          url: json['thumbnails']['standard']['url'],
          width: json['thumbnails']['standard']['width'],
          height: json['thumbnails']['standard']['height'],
        ),
      ),
    );
  }
}

class YoutubeModelThumbnails {
  final YoutubeModelThumbnailType standard;

  const YoutubeModelThumbnails({required this.standard});
}

class YoutubeModelThumbnailType {
  final String url;
  final int width;
  final int height;

  const YoutubeModelThumbnailType({
    required this.url,
    required this.width,
    required this.height,
  });
}

class YoutubeModelContentDetails {
  final String duration;

  const YoutubeModelContentDetails({required this.duration});

  factory YoutubeModelContentDetails.fromJson(json) {
    final youtube_duration = json['duration'];

    String new_str = "";

    bool first_digit_found = false;
    for (var char in youtube_duration.split('')) {
      if (char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57) {
        first_digit_found = true;
        new_str += char;
      } else {
        if (first_digit_found) {
          new_str += ":";
        }
      }
    }

    new_str = new_str.substring(0, new_str.length - 1);

    return YoutubeModelContentDetails(duration: new_str);
  }
}

class YoutubeModelStatistics {
  final int? viewCount;
  final int? likeCount;
  final int? favoriteCount;
  final int? commentCount;

  const YoutubeModelStatistics({
    required this.viewCount,
    required this.likeCount,
    required this.favoriteCount,
    required this.commentCount,
  });

  factory YoutubeModelStatistics.fromJson(json) {
    return YoutubeModelStatistics(
      viewCount: json['viewCount'] == null
          ? null
          : int.parse(json['viewCount']),
      likeCount: json['likeCount'] == null
          ? null
          : int.parse(json['likeCount']),
      favoriteCount: json['favoriteCount'] == null
          ? null
          : int.parse(json['favoriteCount']),
      commentCount: json['commentCount'] == null
          ? null
          : int.parse(json['commentCount']),
    );
  }
}
