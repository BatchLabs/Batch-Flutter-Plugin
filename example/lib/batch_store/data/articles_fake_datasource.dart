import 'model/article.dart';

class ArticlesFakeDatasource {
  static const _allArticles = <Article>[
    const Article(name: "Loafers", price: 280, assetName: "mocassins.webp"),
    const Article(name: "Sunglasses", price: 140, assetName: "aviators.webp"),
    const Article(
        name: "Black Handbag", price: 300, assetName: "sac_noir.webp"),
    const Article(
        name: "High Heels", price: 400, assetName: "chaussure_talon.webp"),
    const Article(name: "Necklace", price: 98, assetName: "collier.webp"),
    const Article(name: "Scarf", price: 110, assetName: "echarpe.webp"),
    const Article(
        name: "Patek Philippe", price: 27150, assetName: "patek_philippe.webp"),
    const Article(name: "Blouse", price: 260, assetName: "blouse.webp"),
    const Article(name: "Coat", price: 420, assetName: "manteau.webp"),
    const Article(
        name: "Submariner", price: 4200, assetName: "submariner.webp"),
    const Article(name: "Sneakers", price: 110, assetName: "basket.webp"),
    const Article(name: "Cap", price: 110, assetName: "casquette.webp"),
  ];

  static List<Article> get allArticles => List.unmodifiable(_allArticles);
}
