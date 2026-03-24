import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/item.dart';
import '../../models/reservation.dart';
import '../../services/reservation_service.dart';
import '../../services/item_service.dart';
import '../../providers/auth_provider.dart' as appProvider;
import '../item/add_item_page.dart';
import '../item/edit_item_page.dart';
import '../auth/login_page.dart';

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  final ReservationService _reservationService = ReservationService();
  final ItemService _itemService = ItemService();

  // Afficher image selon le type
  Widget _buildImage(String imageUrl, {double height = 80}) {
    if (imageUrl.startsWith('data:image')) {
      try {
        final base64Data = imageUrl.split(',')[1];
        return Image.memory(
          base64Decode(base64Data),
          height: height,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.image, color: Colors.grey, size: 40),
        );
      } catch (e) {
        return Icon(Icons.image, color: Colors.grey, size: 40);
      }
    } else {
      return Image.asset(
        imageUrl,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.image, color: Colors.grey, size: 40),
      );
    }
  }

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
            child: Text('Déconnexion',
                style: TextStyle(color: Colors.red)),
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

  // Supprimer un objet
  Future<void> _deleteItem(BuildContext context, Item item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer'),
        content: Text('Voulez-vous supprimer "${item.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Supprimer',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _itemService.deleteItem(item.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Objet supprimé !'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur : $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<appProvider.AuthProvider>(
      context, listen: false
    );
    final userId = authProvider.currentUser?.id ?? '';
    final userName = authProvider.currentUser?.name ?? 'Propriétaire';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec bouton déconnexion
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonjour $userName 👋',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Gérez vos objets',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.logout, color: Colors.red),
                    onPressed: () => _logout(context),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Stats depuis Firestore
              StreamBuilder<List<Reservation>>(
                stream: _reservationService.getOwnerReservations(userId),
                builder: (context, snapshot) {
                  final reservations = snapshot.data ?? [];
                  final totalPrets = reservations
                      .where((r) =>
                          r.status == ReservationStatus.completed)
                      .length;
                  final pending = reservations
                      .where((r) =>
                          r.status == ReservationStatus.pending)
                      .toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats
                      StreamBuilder<List<Item>>(
                        stream: _itemService.getItems(),
                        builder: (context, itemSnapshot) {
                          final totalItems =
                              itemSnapshot.data?.length ?? 0;
                          return Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatCard('$totalItems', 'Objets',
                                  Icons.inventory_2, Colors.red, () {}),
                              _buildStatCard('$totalPrets', 'Prêts',
                                  Icons.handshake, Colors.brown, () {}),
                              _buildStatCard('4.8', 'Note', Icons.star,
                                  Colors.amber, () {}),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: 24),

                      // Demandes en attente
                      Row(
                        children: [
                          Icon(Icons.notifications,
                              color: Colors.orange, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Demandes en attente (${pending.length})',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),

                      if (pending.isEmpty)
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Aucune demande en attente',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        ...pending.map((reservation) =>
                            _buildRequestCard(reservation, context)),
                    ],
                  );
                },
              ),
              SizedBox(height: 24),

              // Mes objets
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.inventory_2,
                          color: Colors.brown, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Mes objets',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('Tout >'),
                  ),
                ],
              ),
              SizedBox(height: 12),

              // Liste des objets depuis Firestore
              StreamBuilder<List<Item>>(
                stream: _itemService.getItems(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final items = snapshot.data ?? [];
                  if (items.isEmpty) {
                    return Center(
                      child: Text(
                        'Aucun objet ajouté',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return _buildMyItemCard(items[index], context);
                    },
                  );
                },
              ),
              SizedBox(height: 20),

              // Bouton Ajouter
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddItemPage()),
                    );
                  },
                  icon: Icon(Icons.add),
                  label: Text('Ajouter un objet'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon,
      Color color, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label,
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(
      Reservation reservation, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey.shade100,
                  child: Center(
                    child: _buildImage(reservation.itemImage, height: 70),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reservation.itemTitle,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 4),
                    Row(children: [
                      Icon(Icons.person, size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(reservation.renterName),
                    ]),
                    SizedBox(height: 4),
                    Row(children: [
                      Icon(Icons.calendar_today,
                          size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        '${_formatDate(reservation.startDate)} → ${_formatDate(reservation.endDate)}',
                        style: TextStyle(fontSize: 12),
                      ),
                    ]),
                    SizedBox(height: 4),
                    Row(children: [
                      Icon(Icons.euro, size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                          '${reservation.totalPrice.toStringAsFixed(0)}€'),
                    ]),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await _reservationService
                        .acceptReservation(reservation.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Réservation acceptée !'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.check, size: 16),
                  label: Text('Accepter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await _reservationService
                        .rejectReservation(reservation.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Réservation refusée !'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.close, size: 16),
                  label: Text('Refuser'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyItemCard(Item item, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image - CORRIGÉ Base64 + Asset
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Center(
                child: _buildImage(item.image, height: 80),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      item.isAvailable
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: item.isAvailable ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      item.isAvailable ? 'Dispo' : 'Réservé',
                      style: TextStyle(
                        color: item.isAvailable
                            ? Colors.green
                            : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  item.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                // Boutons Modifier et Supprimer - FONCTIONNELS
                Row(
                  children: [
                    // Bouton Modifier
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditItemPage(item: item),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.edit,
                            size: 18, color: Colors.orange),
                      ),
                    ),
                    SizedBox(width: 8),
                    // Bouton Supprimer
                    GestureDetector(
                      onTap: () => _deleteItem(context, item),
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.delete,
                            size: 18, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}