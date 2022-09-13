import 'package:batch_flutter_example/batch_store/data/model/article.dart';
import 'package:batch_flutter_example/batch_store/data/model/cart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ArticleDetailsPage extends StatelessWidget {
  const ArticleDetailsPage({
    Key? key,
    required this.article,
  }) : super(key: key);

  final Article article;

  static const TextStyle _articleNameStyle = TextStyle(fontSize: 30);

  static const TextStyle _articlePriceStyle = TextStyle(fontSize: 18);

  void _addToCart(BuildContext context) {
    Provider.of<CartModel>(context, listen: false).addArticle(article);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    article.assetPath,
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 4,
                  ),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 6)),
                  Text(
                    article.name,
                    style: _articleNameStyle,
                  ),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 6)),
                  Text(
                    "${article.price} €",
                    style: _articlePriceStyle,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.green),
                ),
                onPressed: () {
                  _addToCart(context);
                },
                child: Text('Add to cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
