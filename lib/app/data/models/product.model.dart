class Product {
  bool? success;
  List<Categories>? categories;
  List<FeaturedProducts>? featuredProducts;

  Product({this.success, this.categories, this.featuredProducts});

  Product.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['categories'] != null) {
      categories = <Categories>[];
      json['categories'].forEach((v) {
        categories!.add(Categories.fromJson(v));
      });
    }
    if (json['featuredProducts'] != null) {
      featuredProducts = <FeaturedProducts>[];
      json['featuredProducts'].forEach((v) {
        featuredProducts!.add(FeaturedProducts.fromJson(v));
      });
    }
  }
}

class Categories {
  int? id;
  String? name;
  List<Products>? products;

  Categories({this.id, this.name, this.products});

  Categories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(Products.fromJson(v));
      });
    }
  }
}

class Products {
  int? id;
  String? name;
  String? description;
  dynamic price;
  String? image;
  int? isFeatured;
  String? createdAt;
  int? categoryId;
  int? shopkeeperId;
  Shopkeeper? shopkeeper;
  List<String>? sizes; // 🟢 ADD THIS

  Products({
    this.id,
    this.name,
    this.description,
    this.price,
    this.image,
    this.isFeatured,
    this.createdAt,
    this.categoryId,
    this.shopkeeperId,
    this.shopkeeper,
    this.sizes, // 🟢 ADD THIS
  });

  Products.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    price = json['price'];
    image = json['image'];

    if (json['is_featured'] != null) {
      isFeatured = json['is_featured'] is bool
          ? (json['is_featured'] ? 1 : 0)
          : json['is_featured'];
    }

    createdAt = json['created_at'];
    categoryId = json['category_id'];
    shopkeeperId = int.tryParse(json['shopkeeper_id'].toString());

    shopkeeper = json['shopkeeper'] != null
        ? Shopkeeper.fromJson(json['shopkeeper'])
        : null;

    // 🟢 Parse sizes — fallback to default if null
    sizes = json['sizes'] != null
        ? List<String>.from(json['sizes'])
        : ['S', 'M', 'L', 'XL'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'is_featured': isFeatured,
      'created_at': createdAt,
      'category_id': categoryId,
      'shopkeeper_id': shopkeeperId,
      'shopkeeper': shopkeeper?.toJson(),
      'sizes': sizes, // 🟢 ADD THIS
    };
  }
}

class FeaturedProducts {
  int? id;
  String? name;
  String? description;
  dynamic price;
  String? image;
  int? shopkeeperId;
  Shopkeeper? shopkeeper;
  List<String>? sizes; // 🟢 ADD THIS

  FeaturedProducts({
    this.id,
    this.name,
    this.description,
    this.price,
    this.image,
    this.shopkeeperId,
    this.shopkeeper,
    this.sizes, // 🟢 ADD THIS
  });

  FeaturedProducts.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    price = json['price'];
    image = json['image'];
    shopkeeperId = int.tryParse(json['shopkeeper_id'].toString());

    shopkeeper = json['shopkeeper'] != null
        ? Shopkeeper.fromJson(json['shopkeeper'])
        : null;

    // 🟢 Parse sizes — fallback to default if null
    sizes = json['sizes'] != null
        ? List<String>.from(json['sizes'])
        : ['S', 'M', 'L', 'XL'];
  }
}

class Shopkeeper {
  int? id;
  String? name;
  String? shopName;
  String? telegramUsername;
  String? phoneNumber;

  Shopkeeper({this.id, this.name, this.shopName, this.telegramUsername, this.phoneNumber});

  Shopkeeper.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    shopName = json['shop_name'];
    telegramUsername = json['telegram_username'];
    phoneNumber = json['phone_number'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'shop_name': shopName,
      'telegram_username': telegramUsername,
      'phone_number': phoneNumber,
    };
  }
}
class ProductReview {
  final int id;
  final String productName;
  final String comment;
  final double rating;
  final String date;

  ProductReview({
    required this.id,
    required this.productName,
    required this.comment,
    required this.rating,
    required this.date
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      id: json['id'],
      productName: json['product']['name'],
      comment: json['comment'],
      rating: double.parse(json['rating'].toString()),
      date: json['created_at'],
    );
  }
}