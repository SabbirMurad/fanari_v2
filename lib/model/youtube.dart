import 'dart:convert';
import 'package:fanari_v2/env.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

// ── Private sub-models ────────────────────────────────────────────────────────

class _YoutubeModelThumbnail {
  final String url;
  final int width;
  final int height;

  const _YoutubeModelThumbnail({
    required this.url,
    required this.width,
    required this.height,
  });
}

class _YoutubeModelContentDetails {
  final String duration;

  const _YoutubeModelContentDetails({required this.duration});

  factory _YoutubeModelContentDetails.fromJson(Map<String, dynamic> json) {
    final raw = json['duration'] as String;

    // Convert ISO 8601 duration (e.g. "PT4M13S") to "4:13"
    final buffer = StringBuffer();
    bool first_digit_found = false;

    for (final char in raw.split('')) {
      final code = char.codeUnitAt(0);
      if (code >= 48 && code <= 57) {
        first_digit_found = true;
        buffer.write(char);
      } else if (first_digit_found) {
        buffer.write(':');
      }
    }

    final result = buffer.toString();
    return _YoutubeModelContentDetails(
      duration: result.isNotEmpty ? result.substring(0, result.length - 1) : '',
    );
  }
}

class _YoutubeModelStatistics {
  final int? view_count;
  final int? like_count;
  final int? favorite_count;
  final int? comment_count;

  const _YoutubeModelStatistics({
    required this.view_count,
    required this.like_count,
    required this.favorite_count,
    required this.comment_count,
  });

  factory _YoutubeModelStatistics.fromJson(Map<String, dynamic> json) {
    return _YoutubeModelStatistics(
      view_count: json['viewCount'] != null
          ? int.parse(json['viewCount'])
          : null,
      like_count: json['likeCount'] != null
          ? int.parse(json['likeCount'])
          : null,
      favorite_count: json['favoriteCount'] != null
          ? int.parse(json['favoriteCount'])
          : null,
      comment_count: json['commentCount'] != null
          ? int.parse(json['commentCount'])
          : null,
    );
  }
}

// ── Public model ──────────────────────────────────────────────────────────────

class YoutubeModel {
  final String id;
  final String url;
  final String published_at;
  final String title;
  final String channel_title;
  final _YoutubeModelThumbnail thumbnail;
  final _YoutubeModelContentDetails content_details;
  final _YoutubeModelStatistics statistics;

  const YoutubeModel({
    required this.id,
    required this.url,
    required this.published_at,
    required this.title,
    required this.channel_title,
    required this.thumbnail,
    required this.content_details,
    required this.statistics,
  });

  factory YoutubeModel.fromJson(Map<String, dynamic> json) {
    final snippet = json['snippet'] as Map<String, dynamic>;
    final standard = snippet['thumbnails']['standard'] as Map<String, dynamic>;

    return YoutubeModel(
      id: json['id'],
      url: 'https://www.youtube.com/watch?v=${json['id']}',
      published_at: snippet['publishedAt'],
      title: snippet['title'],
      channel_title: snippet['channelTitle'],
      thumbnail: _YoutubeModelThumbnail(
        url: standard['url'],
        width: standard['width'],
        height: standard['height'],
      ),
      content_details: _YoutubeModelContentDetails.fromJson(
        json['contentDetails'],
      ),
      statistics: _YoutubeModelStatistics.fromJson(json['statistics']),
    );
  }

  static String _data_url(String video_id) {
    final api_key = EnvHandler.load().youtube_api_key;

    return "https://www.googleapis.com/youtube/v3/videos?part=snippet,contentDetails,statistics&fields=items(id,snippet(publishedAt,title,channelTitle,thumbnails(standard)),contentDetails(duration),statistics)&id=$video_id&key=$api_key";
  }

  static Future<YoutubeModel?> load(String attachment_id) async {
    try {
      final response = await http.get(
        Uri.parse(_data_url(attachment_id)),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return YoutubeModel.fromJson(
          (jsonDecode(response.body)['items'] as List).first,
        );
      }

      debugPrint('Error fetching YouTube data: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('Error fetching YouTube data: $e');
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
      if (match != null && match.groupCount >= 1) return match.group(1);
    }
    return null;
  }
}
