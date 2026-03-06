class Address { // Renamed from Address to avoid confusion with the data
  bool? message;
  List<AddressData>? addresses;

  Address({this.message, this.addresses});

  Address.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['addresses'] != null) {
      // 🟢 Fix: Correctly map the list of addresses
      addresses = <AddressData>[];
      json['addresses'].forEach((v) {
        addresses!.add(AddressData.fromJson(v));
      });
    }
  }
}

class AddressData {
  int? userId;
  String? fullName;
  String? phone;
  String? street;
  String? label; // 🟢 Add this for icons (Home, Work, Other)
  double? latitude;
  double? longitude;
  String? country;
  int? id;

  AddressData({
    this.userId,
    this.fullName,
    this.phone,
    this.street,
    this.label,
    this.latitude,
    this.longitude,
    this.country,
    this.id,
  });

  AddressData.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    fullName = json['full_name'];
    phone = json['phone'];
    street = json['street'];
    // 🟢 Provide a default 'Home' if label is null to prevent UI errors
    label = json['label'] ?? 'Home';
    latitude = json['latitude'] != null ? double.parse(json['latitude'].toString()) : null;
    longitude = json['longitude'] != null ? double.parse(json['longitude'].toString()) : null;
    country = json['country'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['full_name'] = fullName;
    data['phone'] = phone;
    data['street'] = street;
    data['label'] = label; // 🟢 Include in JSON for saving
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['country'] = country;
    data['id'] = id;
    return data;
  }
}