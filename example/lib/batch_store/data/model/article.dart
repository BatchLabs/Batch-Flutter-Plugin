class Article {
  const Article({
    required this.name,
    required this.price,
    required this.assetName,
  });

  final String name;
  final int price;
  final String assetName;

  String get assetPath => "assets/articles/$assetName";

  @override
  String toString() => "$name";
}
