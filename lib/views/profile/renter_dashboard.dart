import 'package:flutter/material.dart';

class RenterDashboard extends StatefulWidget {
  const RenterDashboard({super.key});

  @override
  State<RenterDashboard> createState() => _RenterDashboardState();
}

class _RenterDashboardState extends State<RenterDashboard> {
  int _selectedTab = 0; // 0: En cours, 1: À venir, 2: Hist.
  
  final List<String> _tabs = ['En cours', 'À venir', 'Hist.'];

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
      'image': 'assets/images/perr.png',
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
            
            // Onglets
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
            SizedBox(height: 20),
            
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
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case 0:
        return _buildEnCours();
      case 1:
        return Center(child: Text('À venir', style: TextStyle(color: Colors.grey)));
      case 2:
        return Center(child: Text('Historique', style: TextStyle(color: Colors.grey)));
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
}