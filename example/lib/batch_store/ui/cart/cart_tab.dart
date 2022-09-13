import 'package:batch_flutter_example/batch_store/data/model/article.dart';
import 'package:batch_flutter_example/batch_store/data/model/cart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart_article_row_item.dart';

class CartTab extends StatelessWidget {
  const CartTab({Key? key}) : super(key: key);

  void _checkout(BuildContext context) {
    Provider.of<CartModel>(context, listen: false).checkout();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartModel>(
      builder: (context, cart, child) {
        List<Article> cartArticles = cart.articles;

        return Column(
          children: [
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) => Divider(),
                itemCount: cartArticles.length,
                itemBuilder: (context, index) {
                  return CartArticleRowItem(
                    article: cartArticles[index],
                  );
                },
              ),
            ),
            buildSummary(context, cart),
          ],
        );
      },
    );
  }

  Widget buildSummary(BuildContext context, CartModel cart) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "Total",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Text(
                  "${cart.total} €",
                  textAlign: TextAlign.end,
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              child: Text("Proceed to checkout"),
              onPressed: () => _checkout(context),
            ),
          ),
        ],
      ),
    );
  }
}
