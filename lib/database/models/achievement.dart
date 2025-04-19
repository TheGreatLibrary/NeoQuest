class Achievement {
  final int id;
  final String title;
  final String image;
  final int status;

  Achievement({
    required this.image,
    required this.title,
    required this.id,
    this.status = 0
  });

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] as int,
      title: map['title'] as String,
      image: map['image'] as String,
      status: map['status'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'status': status,
    };
  }

  Achievement copyWith({int? id, String? title, String? image, int? status}) {
    return Achievement(
        id: id ?? this.id,
        title: title ?? this.title,
        image: image ?? this.image,
        status: status ?? this.status,
    );
  }
}