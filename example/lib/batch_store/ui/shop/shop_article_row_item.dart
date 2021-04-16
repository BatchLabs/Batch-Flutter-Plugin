import 'package:batch_flutter_example/batch_store/data/model/article.dart';
import 'package:flutter/widgets.dart';

class ShopArticleRowItem extends StatelessWidget {
  const ShopArticleRowItem({required this.article});

  final Article article;

  static const TextStyle _articleNameStyle =
      TextStyle(fontWeight: FontWeight.bold);

  static const TextStyle _articlePriceStyle = TextStyle(fontSize: 12);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            article.assetPath,
            fit: BoxFit.contain,
            width: 80,
            height: 80,
          ),
          Padding(padding: const EdgeInsets.symmetric(vertical: 6)),
          Text(
            article.name,
            style: _articleNameStyle,
          ),
          Padding(padding: const EdgeInsets.symmetric(vertical: 6)),
          Text(
            "${article.price} €",
            style: _articlePriceStyle,
          ),
        ],
      ),
    );
  }
}
