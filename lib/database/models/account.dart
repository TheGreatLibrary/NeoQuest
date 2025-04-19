class Account {
  final int? id;
  final String nickname;
  final int age;
  final String? fullName;
  final String? phone;
  final String? postalCode;
  final int money;
  final String? imagePath;

  Account({
    this.id,
    required this.nickname,
    required this.age,
    this.fullName,
    this.phone,
    this.postalCode,
    this.money = 0,
    this.imagePath,
  });

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
        id: map['id'],
        nickname: map['nickname'],
        age: map['age'],
        fullName: map['fullname'],
        phone: map['phone'],
        postalCode: map['postal_code'],
        money: map['money'],
        imagePath: map['image_path']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nickname': nickname,
      'age': age,
      'fullname': fullName,
      'phone': phone,
      'postal_code': postalCode,
      'money': money,
      'image_path': imagePath
    };
  }

  Account copyWith({int? id, String? nickname, int? age, String? fullName, String? phone, String? postalCode, int? money, String? imagePath}) {
    return Account(
        id: id ?? this.id,
        nickname: nickname ?? this.nickname,
        age: age ?? this.age,
        fullName: fullName ?? this.fullName,
        phone: phone ?? this.phone,
        postalCode: postalCode ?? this.postalCode,
        money: money ?? this.money,
        imagePath: imagePath ?? this.imagePath
    );
  }
}