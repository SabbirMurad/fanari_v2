// import 'dart:convert';
// import 'package:fanari_v2/models/view/nhentai.dart';
// import 'package:http/http.dart' as http;

// class Nhentai {
//   Nhentai._constructor();
//   static const _baseDataUrl = 'https://nhentai.net';

//   static Future<NhentaiBookModel?> getBook(book_id) async {
//     try {
//       final url = Uri.parse('${_baseDataUrl}/api/gallery/${book_id}');
//       Map<String, String> headers = {
//         'Content-Type': 'application/json',
//         'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
//         'Accept': 'application/json',
//       };
//       var response = await http.get(
//         url,
//         headers: headers,
//       );

//       if (response.statusCode == 200) {
//         return NhentaiBookModel.fromJson(jsonDecode(response.body));
//       } else {
//         print('');
//         print('Error getting book from nhentai');
//         print(response.statusCode);
//         print('');
//         return null;
//       }
//     } catch (e) {
//       print('');
//       print('Error getting book from nhentai');
//       print(e);
//       print('');
//       return null;
//     }
//   }
// }
