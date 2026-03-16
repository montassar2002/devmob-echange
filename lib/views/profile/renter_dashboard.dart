import 'package:flutter/material.dart';
import '../../models/item.dart';
import '../review/leave_review_page.dart';

class RenterDashboard extends StatefulWidget {
  const RenterDashboard({super.key});

  @override
  State<RenterDashboard> createState() => _RenterDashboardState();
}

class _RenterDashboardState extends State<RenterDashboard> {
  int _selectedTab = 1; // 0: En cours, 1: Hist.
  
  final List<String> _tabs = ['En cours', 'Hist.'];

  // Données de test
  final List<Map<String, dynamic>> _pendingReservations = [
    {
      'image': 'assets/images/perceuse.png',
      'title': 'Perceuse Bosch',
      'ownerName': 'Marc D.',
      'ownerRating': 4.9,
      'dates': '15-18 février',
      'price': '45€',
      'duration': '3 jours',
      'status': 'En attente',
      'statusColor': Colors.orange,
    },
  ];

  final List<Map<String, dynamic>> _confirmedReservations = [
    {
      'image': 'assets/images/perce.png',
      'title': 'Appareil Canon EOS',
      'ownerName': 'Sophie L.',
      'ownerRating': 5.0,
      'dates': '20-22 février',
      'price': '60€',
      'duration': '3 jours',
      'status': 'Confirmer',
      'statusColor': Colors.green,
    },
    {
      'image': 'assets/images/tente.png',
      'title': 'Tente 4p',
      'ownerName': 'Paul R.',
      'ownerRating': 4.5,
      'dates': '01-04 mars',
      'price': '42€',
      'duration': '4 jours',
      'status': 'Confirmer',
      'statusColor': Colors.green,
    },
  ];

  // Historique - réservations terminées
  final List<Map<String, dynamic>> _historyReservations = [
    {
      'image': 'assets/images/velo.png',
      'title': 'Vélo VTT Trek 2024',
      'ownerName': 'Jean M.',
      'ownerRating': 4.8,
      'dates': '01-05 février',
      'price': '40€',
      'duration': '5 jours',
      'status': 'Terminée',
      'canReview': true,
    },
    {
      'image': 'assets/images/perr.png',
      'title': 'Tondeuse Bosch',
      'ownerName': 'Marie D.',
      'ownerRating': 5.0,
      'dates': '15-20 janvier',
      'price': '30€',
      'duration': '5 jours',
      'status': 'Terminée',
      'canReview': false,
    },
  ];

  String _searchQuery = '';
  int _selectedBottomIndex = 3; // Icône réservations sélectionnée

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Mes Réservations',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // Onglets (2 seulement)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _tabs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final label = entry.value;
                  final isSelected = index == _selectedTab;
                  
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTab = index;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 8),
                        padding: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Color(0xFF2196F3) : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 16),
            
            // Contenu selon l'onglet
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
      
      // BOTTOM NAVIGATION BAR
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedBottomIndex,
        onTap: (index) {
          setState(() {
            _selectedBottomIndex = index;
          });
          // Navigation
          switch (index) {
            case 0: // Accueil
              Navigator.pop(context);
              break;
            case 1: // Recherche
              // TODO: Naviguer vers recherche
              break;
            case 2: // Ajouter
              // TODO: Naviguer vers ajouter objet
              break;
            case 3: // Réservations (déjà ici)
              break;
            case 4: // Profil
              // TODO: Naviguer vers profil
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
            icon: Icon(Icons.assignment_outlined),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: '',
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case 0:
        return _buildEnCours();
      case 1:
        return _buildHistorique();
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildEnCours() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En attente
        Row(
          children: [
            Icon(Icons.hourglass_empty, size: 16),
            SizedBox(width: 4),
            Text(
              'En attente (${_pendingReservations.length})',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        ..._pendingReservations.map((reservation) => _buildReservationCard(reservation)),
        SizedBox(height: 24),
        
        // Confirmées
        Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 16),
            SizedBox(width: 4),
            Text(
              'Confirmées (${_confirmedReservations.length})',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        ..._confirmedReservations.map((reservation) => _buildReservationCard(reservation)),
        SizedBox(height: 100),
      ],
    );
  }

  Widget _buildHistorique() {
    // Filtrer les réservations selon la recherche
    final filteredHistory = _historyReservations.where((reservation) {
      final query = _searchQuery.toLowerCase();
      return reservation['title'].toString().toLowerCase().contains(query) ||
             reservation['ownerName'].toString().toLowerCase().contains(query);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recherche
        TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Rechercher...',
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        SizedBox(height: 12),
        
        // Filtre
        Text(
          'Filtrer par objet',
          style: TextStyle(color: Colors.grey),
        ),
        SizedBox(height: 20),
        
        // Terminées
        Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 16),
            SizedBox(width: 4),
            Text(
              'Terminées (${filteredHistory.length})',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        ...filteredHistory.map((reservation) => _buildHistoryCard(reservation)),
        SizedBox(height: 100),
      ],
    );
  }

  Widget _buildReservationCard(Map<String, dynamic> reservation) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              reservation['image'],
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 12),
          
          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reservation['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(reservation['ownerName']),
                    SizedBox(width: 8),
                    Icon(Icons.star, size: 14, color: Colors.orange),
                    Text('${reservation['ownerRating']}'),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(reservation['dates']),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.euro, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Text('${reservation['price']} - ${reservation['duration']}'),
                  ],
                ),
                SizedBox(height: 8),
                // Badge statut
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: reservation['statusColor'],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (reservation['status'] == 'Confirmer')
                        Icon(Icons.check, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        reservation['status'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> reservation) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  reservation['image'],
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 12),
              
              // Infos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reservation['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.person, size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(reservation['ownerName']),
                        SizedBox(width: 8),
                        Icon(Icons.star, size: 14, color: Colors.orange),
                        Text('${reservation['ownerRating']}'),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(reservation['dates']),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.euro, size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Text('${reservation['price']} - ${reservation['duration']}'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          // Boutons d'action
          if (reservation['canReview']) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.check, size: 16),
                    label: Text('Confirmer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LeaveReviewPage(item: Item.sampleItems[0]),
                        ),
                      );
                    },
                    icon: Icon(Icons.star, size: 16, color: Colors.white),
                    label: Text('Laisser un avis'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.check, size: 16),
                    label: Text('Confirmer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.star, size: 16, color: Colors.orange),
                SizedBox(width: 4),
                Text(
                  'Avis déjà laissé',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    // TODO: Voir l'avis
                  },
                  child: Row(
                    children: [
                      Icon(Icons.visibility, size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        'Voir l\'avis',
                        style: TextStyle(
                          color: Colors.grey,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}