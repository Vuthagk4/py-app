class CartResponse {
  Cart? cart;
  int? total;
  int? count;

  CartResponse({this.cart, this.total, this.count});

  CartResponse.fromJson(Map<String, dynamic> json) {
    cart = json['cart'] != null ? new Cart.fromJson(json['cart']) : null;
    total = json['total'];
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.cart != null) {
      data['cart'] = this.cart!.toJson();
    }
    data['total'] = this.total;
    data['count'] = this.count;
    return data;
  }
}

class Cart {
  int? id;
  int? userId;
  int? total;
  String? status;
  List<Items>? items;

  Cart({this.id, this.userId, this.total, this.status, this.items});

  Cart.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    total = json['total'];
    status = json['status'];
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(new Items.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['total'] = this.total;
    data['status'] = this.status;
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Items {
  int? id;
  int? cartId;
  int? productId;
  int? quantity;
  int? price;
  String? size; // 🟢 ADD
  String? createdAt;
  String? updatedAt;
  Product? product;

  Items({
    this.id,
    this.cartId,
    this.productId,
    this.quantity,
    this.price,
    this.size, // 🟢 ADD
    this.createdAt,
    this.updatedAt,
    this.product,
  });

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    cartId = json['cart_id'];
    productId = json['product_id'];
    quantity = json['quantity'];
    price = json['price'];
    size = json['size']; // 🟢 ADD
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    product = json['product'] != null ? Product.fromJson(json['product']) : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cart_id': cartId,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
      'size': size, // 🟢 ADD
      'created_at': createdAt,
      'updated_at': updatedAt,
      if (product != null) 'product': product!.toJson(),
    };
  }
}

class Product {
  int? id;
  String? name;
  String? description;
  int? price;
  String? image;
  int? isFeatured;
  int? categoryId;
  String? createdAt;
  String? updatedAt;

  Product(
      {this.id,
        this.name,
        this.description,
        this.price,
        this.image,
        this.isFeatured,
        this.categoryId,
        this.createdAt,
        this.updatedAt});

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    price = json['price'];
    image = json['image'];
    isFeatured = json['is_featured'];
    categoryId = json['category_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['price'] = this.price;
    data['image'] = this.image;
    data['is_featured'] = this.isFeatured;
    data['category_id'] = this.categoryId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
