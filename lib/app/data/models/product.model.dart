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

  Products({
    this.id,
    this.name,
    this.description,
    this.price,
    this.image,
    this.isFeatured,
    this.createdAt,
    this.categoryId,
  });

  Products.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    price = json['price'];
    image = json['image'];

    // 🔴 THE FIX: Safely parse is_featured whether it comes as a bool or an int
    if (json['is_featured'] != null) {
      isFeatured = json['is_featured'] is bool
          ? (json['is_featured'] ? 1 : 0)
          : json['is_featured'];
    }

    createdAt = json['created_at'];
    categoryId = json['category_id'];
  }

  // 🔴 MOVED: This is now safely inside the Products class!
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
    };
  }
}

class FeaturedProducts {
  int? id;
  String? name;
  String? description;
  dynamic price;
  String? image;

  FeaturedProducts({this.id, this.name, this.description, this.price, this.image});

  FeaturedProducts.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    price = json['price'];
    image = json['image'];
  }
}