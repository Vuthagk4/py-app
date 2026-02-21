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
  dynamic price; // CHANGED FROM INT TO DYNAMIC to handle "90.00"
  String? image;
  int? isFeatured;
  String? createdAt;

  Products({this.id, this.name, this.description, this.price, this.image, this.isFeatured});

  Products.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    price = json['price']; // Now accepts String or Int
    image = json['image'];
    isFeatured = json['is_featured'];

  }
}

class FeaturedProducts {
  int? id;
  String? name;
  String? description;
  dynamic price; // CHANGED FROM INT TO DYNAMIC
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