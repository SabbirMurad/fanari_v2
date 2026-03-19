import 'package:fanari_v2/model/media/image.dart';

class ProductModel {
  final String title;
  final int price;
  final int rating;
  final ImageModel image;
  final bool favorite;

  const ProductModel({
    required this.title,
    required this.price,
    required this.rating,
    required this.image,
    required this.favorite,
  });
}
