import 'package:flutter/material.dart';
import '../../widgets/item_card.dart';
import 'search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<String> categories = ['Outils', 'Sport', 'Tech', 'Maison', 'Loisirs'];
  
  // Objets populaires
final List<Map<String, dynamic>> popularItems = [
  {
    'image': 'assets/images/perceuse.png',  // ← Chemin local
    'title': 'Perceuse',
    'isAvailable': true,
    'rating': 5.0,
    'location': 'Paris',
    'price': 15.0,
  },
  {
    'image': 'assets/images/velo.png',  // ← Chemin local
    'title': 'Vélo VTT',
    'isAvailable': false,
    'rating': 5.0,
    'location': 'Marseille',
    'price': 8.0,
  },
];

// Récemment ajoutés
final List<Map<String, dynamic>> recentItems = [
  {
    'image': 'assets/images/tente.png',  // ← Chemin local
    'title': 'Tente',
    'isAvailable': true,
    'rating': 4.0,
    'location': 'USA',
    'price': 7.0,
  },
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header bleu
              Container(
                width: double.infinity,
                color: Color(0xFF2196F3),
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Row(
                  children: [
                    Icon(Icons.inventory_2, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'DEVMOB - Echange',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Barre de recherche
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Rechercher l\'objet...',
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SearchPage()),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.tune, color: Colors.grey),
                        onPressed: () {
                          // Ouvrir filtres
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Catégories
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Catégories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: categories.map((category) {
                    return Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(category),
                        backgroundColor: Colors.grey.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 24),

              // Objets populaires
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange, size: 20),
                    SizedBox(width: 4),
                    Text(
                      'Objets populaires',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 16, top: 4),
                child: Text(
                  'Disponible',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
              SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: popularItems.map((item) {
                    return ItemCard(
                      image: item['image'],
                      title: item['title'],
                      isAvailable: item['isAvailable'],
                      rating: item['rating'],
                      location: item['location'],
                      price: item['price'],
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 24),

              // Récemment ajoutés
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.new_releases, color: Colors.blue, size: 20),
                    SizedBox(width: 4),
                    Text(
                      'Récemment ajoutés',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: recentItems.map((item) {
                    return ItemCard(
                      image: item['image'],
                      title: item['title'],
                      isAvailable: item['isAvailable'],
                      rating: item['rating'],
                      location: item['location'],
                      price: item['price'],
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 100), // Espace pour bottom nav
            ],
          ),
        ),
      ),
      
      // Bottom Navigation
      
      // Bottom Navigation avec 5 icônes
bottomNavigationBar: BottomNavigationBar(
  currentIndex: _selectedIndex,
  onTap: (index) {
    setState(() {
      _selectedIndex = index;
    });
    // Navigation vers les différentes pages
    switch (index) {
      case 0:
        // Accueil - déjà sur cette page
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SearchPage()),
        );
        break;
      case 2:
        // TODO: Naviguer vers Ajouter Objet
        break;
      case 3:
        // TODO: Naviguer vers Évaluations/Avis
        break;
      case 4:
        // TODO: Naviguer vers Profil
        break;
    }
  },
  type: BottomNavigationBarType.fixed,
  selectedItemColor: Color(0xFF6B4EFF),
  unselectedItemColor: Colors.grey,
  showSelectedLabels: false,
  showUnselectedLabels: false,
  items: [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: '',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.search),
      label: '',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.add_circle_outline),
      label: '',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.assignment_outlined), // Avis/Évaluations
      label: '',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline), // Profil
      label: '',
    ),
  ],
),
    );
  }
}