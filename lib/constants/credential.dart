class AppCredentials {
  static const String domain = 'https://bitlaab.com:446';
  static const String wsDomain = 'wss://bitlaab.com:446';

  static const String youtubeApiKey = "AIzaSyC_0U4x3ihd09sR3UQCRkJfJ8j2fbGDiJQ";

  static String getYoutubeBasicDataUrl(String videoId) =>
      "https://www.googleapis.com/youtube/v3/videos?part=snippet,contentDetails,statistics&fields=items(id,snippet(publishedAt,title,channelTitle,thumbnails(standard)),contentDetails(duration),statistics)&id=$videoId&key=$youtubeApiKey";
}
