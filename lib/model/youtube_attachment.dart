class YoutubeAttachment {
  final String id;
  final String url;
  final YoutubeAttachmentSnippet snippet;
  final YoutubeAttachmentContentDetails contentDetails;
  final YoutubeAttachmentStatistics statistics;

  const YoutubeAttachment({
    required this.id,
    required this.url,
    required this.snippet,
    required this.contentDetails,
    required this.statistics,
  });

  factory YoutubeAttachment.fromJson(json) {
    return YoutubeAttachment(
      id: json['id'],
      url: 'https://www.youtube.com/watch?v=${json['id']}',
      snippet: YoutubeAttachmentSnippet.fromJson(json['snippet']),
      contentDetails:
          YoutubeAttachmentContentDetails.fromJson(json['contentDetails']),
      statistics: YoutubeAttachmentStatistics.fromJson(json['statistics']),
    );
  }
}

class YoutubeAttachmentSnippet {
  final String publishedAt;
  final String title;
  final String channelTitle;
  final YoutubeAttachmentThumbnails thumbnails;

  const YoutubeAttachmentSnippet({
    required this.publishedAt,
    required this.title,
    required this.channelTitle,
    required this.thumbnails,
  });

  factory YoutubeAttachmentSnippet.fromJson(json) {
    return YoutubeAttachmentSnippet(
      publishedAt: json['publishedAt'],
      title: json['title'],
      channelTitle: json['channelTitle'],
      thumbnails: YoutubeAttachmentThumbnails(
        standard: YoutubeAttachmentThumbnailType(
          url: json['thumbnails']['standard']['url'],
          width: json['thumbnails']['standard']['width'],
          height: json['thumbnails']['standard']['height'],
        ),
      ),
    );
  }
}

class YoutubeAttachmentThumbnails {
  final YoutubeAttachmentThumbnailType standard;

  const YoutubeAttachmentThumbnails({
    required this.standard,
  });
}

class YoutubeAttachmentThumbnailType {
  final String url;
  final int width;
  final int height;

  const YoutubeAttachmentThumbnailType({
    required this.url,
    required this.width,
    required this.height,
  });
}

class YoutubeAttachmentContentDetails {
  final String duration;

  const YoutubeAttachmentContentDetails({
    required this.duration,
  });

  factory YoutubeAttachmentContentDetails.fromJson(json) {
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

    return YoutubeAttachmentContentDetails(
      duration: new_str,
    );
  }
}

class YoutubeAttachmentStatistics {
  final int? viewCount;
  final int? likeCount;
  final int? favoriteCount;
  final int? commentCount;

  const YoutubeAttachmentStatistics({
    required this.viewCount,
    required this.likeCount,
    required this.favoriteCount,
    required this.commentCount,
  });

  factory YoutubeAttachmentStatistics.fromJson(json) {
    return YoutubeAttachmentStatistics(
      viewCount:
          json['viewCount'] == null ? null : int.parse(json['viewCount']),
      likeCount:
          json['likeCount'] == null ? null : int.parse(json['likeCount']),
      favoriteCount: json['favoriteCount'] == null
          ? null
          : int.parse(json['favoriteCount']),
      commentCount:
          json['commentCount'] == null ? null : int.parse(json['commentCount']),
    );
  }
}
