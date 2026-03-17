class Item {
  final String id;
  final String image;
  final String title;
  final String description;
  final String owner;
  final String ownerId;
  final double ownerRating;
  final String memberSince;
  final String category;
  final bool isAvailable;
  final double rating;
  final String location;
  final double price;
  final String? distance;
  final DateTime? createdAt;

  Item({
    required this.id,
    required this.image,
    required this.title,
    required this.description,
    required this.owner,
    this.ownerId = '',
    required this.ownerRating,
    required this.memberSince,
    required this.category,
    required this.isAvailable,
    required this.rating,
    required this.location,
    required this.price,
    this.distance,
    this.createdAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] ?? '',
      image: json['image']?.toString() ?? 'assets/images/perceuse.png', 
      title: json['title']?.toString() ?? 'Sans titre',
      description: json['description']?.toString() ?? '',
      owner: json['owner']?.toString() ?? '',
      ownerId: json['ownerId']?.toString() ?? '',
      ownerRating: double.tryParse(json['ownerRating']?.toString() ?? '0') ?? 0.0,
      memberSince: json['memberSince']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      isAvailable: json['isAvailable'] == true || json['isAvailable'] == 'true',
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      location: json['location']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      distance: json['distance']?.toString(),
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'title': title,
      'description': description,
      'owner': owner,
      'ownerId': ownerId,
      'ownerRating': ownerRating,
      'memberSince': memberSince,
      'category': category,
      'isAvailable': isAvailable,
      'rating': rating,
      'location': location,
      'price': price,
      'distance': distance,
      'createdAt': createdAt ?? DateTime.now(),
    };
  }

  static List<Item> get sampleItems => [
    Item(
      id: '1',
      image: 'assets/images/perceuse.png',
      title: 'Perceuse Bosch PSB',
      description: 'Perceuse professionnelle idéale pour tous travaux.',
      owner: 'Marc D.',
      ownerId: '',
      ownerRating: 4.9,
      memberSince: '2023',
      category: 'Outils',
      isAvailable: true,
      rating: 5.0,
      location: 'Paris',
      price: 15.0,
      distance: '2km',
      createdAt: DateTime.now(),
    ),
    Item(
      id: '2',
      image: 'assets/images/velo.png',
      title: 'Vélo VTT',
      description: 'Vélo tout terrain en excellent état.',
      owner: 'Sophie L.',
      ownerId: '',
      ownerRating: 4.7,
      memberSince: '2022',
      category: 'Sport',
      isAvailable: false,
      rating: 5.0,
      location: 'Marseille',
      price: 8.0,
      distance: '5km',
      createdAt: DateTime.now(),
    ),
    Item(
      id: '3',
      image: 'assets/images/tente.png',
      title: 'Tente Camping',
      description: 'Tente 3 places imperméable.',
      owner: 'Jean P.',
      ownerId: '',
      ownerRating: 4.8,
      memberSince: '2024',
      category: 'Sport',
      isAvailable: true,
      rating: 4.0,
      location: 'USA',
      price: 7.0,
      distance: '10km',
      createdAt: DateTime.now(),
    ),
  ];
}