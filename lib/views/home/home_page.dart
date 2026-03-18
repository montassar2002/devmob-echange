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
              // Header bleu avec bouton déconnexion
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
                    // Bouton déconnexion
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
                            hintText: 'Rechercher l\'objet...',
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SearchPage()
                              ),
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
                        onPressed: () {},
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
              SizedBox(height: 12),
              StreamBuilder<List<Item>>(
                stream: _itemService.getPopularItems(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final items = snapshot.hasData && snapshot.data!.isNotEmpty
                      ? snapshot.data!
                      : Item.sampleItems.sublist(0, 2);
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: items.map((item) {
                        return ItemCard(item: item);
                      }).toList(),
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
              StreamBuilder<List<Item>>(
                stream: _itemService.getRecentItems(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final items = snapshot.hasData && snapshot.data!.isNotEmpty
                      ? snapshot.data!
                      : [Item.sampleItems[2]];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: items.map((item) {
                        return ItemCard(item: item);
                      }).toList(),
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddItemPage()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RenterDashboard()),
              );
              break;
            case 4:
              if (authProvider.isOwner) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OwnerDashboard()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RenterDashboard()),
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