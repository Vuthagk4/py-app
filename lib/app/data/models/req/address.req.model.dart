class AddressRequest {
  String? message;
  Address? address;

  AddressRequest({this.message, this.address});

  AddressRequest.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    address =
    json['addresses'] != null ? new Address.fromJson(json['addresses']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.address != null) {
      data['addresses'] = this.address!.toJson();
    }
    return data;
  }
}

class Address {
  int? userId;
  String? fullName;
  String? phone;
  String? street;
  double? latitude;
  double? longitude;
  String? country;
  String? updatedAt;
  String? createdAt;
  int? id;

  Address(
      {this.userId,
        this.fullName,
        this.phone,
        this.street,
        this.latitude,
        this.longitude,
        this.country,
        this.updatedAt,
        this.createdAt,
        this.id});

  Address.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    fullName = json['full_name'];
    phone = json['phone'];
    street = json['street'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    country = json['country'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['full_name'] = this.fullName;
    data['phone'] = this.phone;
    data['street'] = this.street;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['country'] = this.country;
    data['updated_at'] = this.updatedAt;
    data['created_at'] = this.createdAt;
    data['id'] = this.id;
    return data;
  }
}
