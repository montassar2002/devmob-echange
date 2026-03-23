import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/item_card.dart';
import 'search_page.dart';
import '../../models/item.dart';
import '../../providers/auth_provider.dart' as appProvider;
import '../../services/item_service.dart';
import '../profile/owner_dashboard.dart';
import '../profile/renter_dashboard.dart';
import '../item/add_item_page.dart';
import '../auth/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final ItemService _itemService = ItemService();
  String _selectedCategory = '';

  final List<String> categories = [
    'Outils', 'Sport', 'Tech', 'Maison', 'Loisirs'
  ];

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Déconnexion'),
        content: Text('Voulez-vous vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Déconnexion',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final authProvider = Provider.of<appProvider.AuthProvider>(
        context, listen: false
      );
      await authProvider.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    }
  }

  // Fonction de filtrage centralisée
  List<Item> _filterItems(List<Item> items) {
    if (_selectedCategory.isEmpty) return items;
    
    return items.where((item) {
      final itemCategory = item.category.trim().toLowerCase();
      final selectedCategory = _selectedCategory.trim().toLowerCase();
      print('🔍 Comparaison: "$itemCategory" == "$selectedCategory" → ${itemCategory == selectedCategory}');
      return itemCategory == selectedCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<appProvider.AuthProvider>(
      context, listen: false
    );

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
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
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
                    IconButton(
                      icon: Icon(Icons.logout, color: Colors.white),
                      onPressed: () => _logout(context),
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
                            hintText: authProvider.isOwner
                                ? 'Recherche non disponible'
                                : 'Rechercher l\'objet...',
                            prefixIcon:
                                Icon(Icons.search, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 14),
                          ),
                          onTap: () {
                            if (!authProvider.isOwner) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SearchPage(),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'La recherche est réservée aux locataires',
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
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
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),

              // Catégories cliquables
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
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_selectedCategory == category) {
                              _selectedCategory = ''; // Désélectionner
                            } else {
                              _selectedCategory = category;
                            }
                          });
                          print('🏷️ Catégorie sélectionnée: $_selectedCategory');
                        },
                        child: Chip(
                          label: Text(
                            category,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          backgroundColor: isSelected
                              ? Color(0xFF2196F3)
                              : Colors.grey.shade200,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
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
                    if (_selectedCategory.isNotEmpty) ...[
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _selectedCategory = ''),
                        child: Chip(
                          label: Text(
                            '$_selectedCategory ✕',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: Color(0xFF2196F3),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 12),

              // StreamBuilder Objets populaires
              StreamBuilder<List<Item>>(
                stream: _itemService.getPopularItems(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  }

                  // Récupérer tous les items
                  var allItems = snapshot.hasData && snapshot.data!.isNotEmpty
                      ? snapshot.data!
                      : Item.sampleItems;

                  // Debug
                  print('📊 Total items: ${allItems.length}');
                  for (var item in allItems) {
                    print('  → ${item.title} | category: "${item.category}"');
                  }

                  // Filtrer
                  var filteredItems = _filterItems(allItems);
                  print('✅ Items filtrés: ${filteredItems.length}');

                  if (filteredItems.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            _selectedCategory.isEmpty
                                ? 'Aucun objet disponible'
                                : 'Aucun objet dans "$_selectedCategory"',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: filteredItems
                          .map((item) => ItemCard(item: item))
                          .toList(),
                    ),
                  );
                },
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

              // StreamBuilder Récemment ajoutés
              StreamBuilder<List<Item>>(
                stream: _itemService.getRecentItems(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var allItems = snapshot.hasData && snapshot.data!.isNotEmpty
                      ? snapshot.data!
                      : [Item.sampleItems[2]];

                  // Filtrer
                  var filteredItems = _filterItems(allItems);

                  if (filteredItems.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            _selectedCategory.isEmpty
                                ? 'Aucun objet récent'
                                : 'Aucun objet récent dans "$_selectedCategory"',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    );
                  }

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: filteredItems
                          .map((item) => ItemCard(item: item))
                          .toList(),
                    ),
                  );
                },
              ),
              SizedBox(height: 100),
            ],
          ),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          switch (index) {
            case 0:
              break;
            case 1:
              if (!authProvider.isOwner) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchPage()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Cette fonctionnalité est pour les locataires',
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
              break;
            case 2:
              if (authProvider.isOwner) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddItemPage()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Cette fonctionnalité est pour les propriétaires',
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
              break;
            case 3:
              if (!authProvider.isOwner) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RenterDashboard(),
                  ),
                );
              }
              break;
            case 4:
              if (authProvider.isOwner) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OwnerDashboard(),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RenterDashboard(),
                  ),
                );
              }
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF6B4EFF),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline), label: ''),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined), label: ''),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), label: ''),
        ],
      ),
    );
  }
}