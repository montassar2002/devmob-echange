class Item {
  final String id;
  final String image;
  final String title;
  final String description;
  final String owner;
  final double ownerRating;
  final String memberSince;
  final String category;
  final bool isAvailable;
  final double rating;
  final String location;
  final double price;
  final String? distance;

  Item({
    required this.id,
    required this.image,
    required this.title,
    required this.description,
    required this.owner,
    required this.ownerRating,
    required this.memberSince,
    required this.category,
    required this.isAvailable,
    required this.rating,
    required this.location,
    required this.price,
    this.distance,
  });

  // Données de test
  static List<Item> get sampleItems => [
    Item(
      id: '1',
      image: 'assets/images/perce.png',
      title: 'Perceuse Bosch PSB',
      description: 'Perceuse professionnelle idéale pour tous travaux. Puissance 750W, mandrin 13mm. Parfait état.',
      owner: 'Marc D.',
      ownerRating: 4.9,
      memberSince: '2023',
      category: 'Outils',
      isAvailable: true,
      rating: 5.0,
      location: 'Paris',
      price: 15.0,
      distance: '2km',
    ),
    Item(
      id: '2',
      image: 'assets/images/velo.png',
      title: 'Vélo VTT',
      description: 'Vélo tout terrain en excellent état. 21 vitesses, freins à disque. Parfait pour randonnées.',
      owner: 'Sophie L.',
      ownerRating: 4.7,
      memberSince: '2022',
      category: 'Sport',
      isAvailable: false,
      rating: 5.0,
      location: 'Marseille',
      price: 8.0,
      distance: '5km',
    ),
    Item(
      id: '3',
      image: 'assets/images/tente.png',
      title: 'Tente Camping',
      description: 'Tente 3 places, imperméable. Idéale pour camping en famille. Facile à monter.',
      owner: 'Jean P.',
      ownerRating: 4.8,
      memberSince: '2024',
      category: 'Sport',
      isAvailable: true,
      rating: 4.0,
      location: 'USA',
      price: 7.0,
      distance: '10km',
    ),
  ];
}