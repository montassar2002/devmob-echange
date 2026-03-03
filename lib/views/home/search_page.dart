import 'package:flutter/material.dart';
import '../../models/item.dart';
import '../item/item_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final searchController = TextEditingController();
  
  // Filtres actifs - VIDE par défaut
  List<String> activeFilters = [];
  
  // Utilisation du Model Item
  final List<Item> allItems = Item.sampleItems;

  // Résultats filtrés
  List<Item> filteredItems = [];

  @override
  void initState() {
    super.initState();
    // Au début, afficher tous les objets
    filteredItems = List.from(allItems);
    
    // Écouter les changements de texte
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredItems = allItems.where((item) {
        // Filtre par texte
        final matchesSearch = query.isEmpty || 
            item.title.toLowerCase().contains(query);
        
        // Filtre par catégorie et lieu
        final matchesCategory = activeFilters.isEmpty || 
            activeFilters.contains(item.category) ||
            activeFilters.contains(item.location);
        
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _removeFilter(String filter) {
    setState(() {
      activeFilters.remove(filter);
      _onSearchChanged(); // Rafraîchir les résultats
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Recherche',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barre de recherche
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Rechercher...',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
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
                      // Ouvrir tous les filtres
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            
            // Filtres actifs
            if (activeFilters.isNotEmpty) ...[
              Text(
                'Filtres actifs :',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: activeFilters.map((filter) {
                  return Chip(
                    avatar: Icon(
                      filter == 'Outils' || filter == 'Sport' 
                          ? Icons.build 
                          : Icons.location_on,
                      size: 16,
                      color: Colors.grey.shade700,
                    ),
                    label: Text(filter),
                    backgroundColor: Colors.grey.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    deleteIcon: Icon(Icons.close, size: 16),
                    onDeleted: () => _removeFilter(filter),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
            ],
            
            // Bouton Tous les filtres
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Tous les filtres',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            
            // Nombre de résultats
            Text(
              '${filteredItems.length} résultat(s)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 12),
            
            // Résultats
            if (filteredItems.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'Aucun résultat trouvé',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return _buildSearchResultCard(item);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultCard(Item item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDetailPage(item: item),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image - Style Amazon
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                height: 150,
                width: double.infinity,
                color: Colors.grey.shade100,
                child: Center(
                  child: Image.asset(
                    item.image,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  // Note et distance
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.orange, size: 16),
                      SizedBox(width: 4),
                      Text(
                        '${item.rating}',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.location_on, color: Colors.red, size: 16),
                      SizedBox(width: 4),
                      Text(
                        item.distance ?? '',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Prix
                  Row(
                    children: [
                      Icon(Icons.euro, size: 16, color: Colors.grey),
                      Text(
                        '${item.price.toStringAsFixed(0)}€/jour',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Statut
                  Row(
                    children: [
                      Icon(
                        item.isAvailable ? Icons.check_circle : Icons.cancel,
                        color: item.isAvailable ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        item.isAvailable ? 'Disponible' : 'Réservé',
                        style: TextStyle(
                          color: item.isAvailable ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }
}