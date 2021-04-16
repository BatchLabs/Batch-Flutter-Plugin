import 'package:batch_flutter_example/batch_store/data/model/article.dart';
import 'package:flutter/widgets.dart';

class CartArticleRowItem extends StatelessWidget {
  const CartArticleRowItem({required this.article});

  final Article article;

  static const TextStyle _articleNameStyle =
      TextStyle(fontWeight: FontWeight.bold);

  static const TextStyle _articlePriceStyle = TextStyle(fontSize: 12);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            article.assetPath,
            fit: BoxFit.contain,
            width: 50,
            height: 50,
          ),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 6)),
          Expanded(
            child: Text(
              article.name,
              style: _articleNameStyle,
            ),
          ),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 6)),
          Text(
            "${article.price} €",
            style: _articlePriceStyle,
          ),
        ],
      ),
    );
  }
}
