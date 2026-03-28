import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../models/reservation.dart';
import '../../models/item.dart';
import '../../services/reservation_service.dart';
import '../../providers/auth_provider.dart' as appProvider;
import '../review/leave_review_page.dart';
import '../auth/login_page.dart';

class RenterDashboard extends StatefulWidget {
  const RenterDashboard({super.key});

  @override
  State<RenterDashboard> createState() => _RenterDashboardState();
}

class _RenterDashboardState extends State<RenterDashboard> {
  int _selectedTab = 0;
  final List<String> _tabs = ['En cours', 'Hist.'];
  final ReservationService _reservationService = ReservationService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedBottomIndex = 3;

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vous déconnecter ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final authProvider = Provider.of<appProvider.AuthProvider>(context, listen: false);
      await authProvider.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<appProvider.AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Mes Réservations', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.logout, color: Colors.red), onPressed: () => _logout(context)),
                ],
              ),
            ),

            // Onglets
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                          _searchQuery = '';
                          _searchController.clear();
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF2196F3) : Colors.grey.shade200,
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
            const SizedBox(height: 16),

            // Contenu principal
            Expanded(
              child: StreamBuilder<List<Reservation>>(
                stream: _reservationService.getRenterReservations(userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Aucune réservation', style: TextStyle(color: Colors.grey)));
                  }

                  final allReservations = snapshot.data!;
                  return _selectedTab == 0 
                      ? _buildEnCours(allReservations) 
                      : _buildHistorique(allReservations);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedBottomIndex,
        onTap: (index) {
          setState(() => _selectedBottomIndex = index);
          if (index == 0) Navigator.pop(context);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF6B4EFF),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
        ],
      ),
    );
  }

  // ==================== EN COURS ====================
  Widget _buildEnCours(List<Reservation> reservations) {
    final pending = reservations.where((r) => r.status == ReservationStatus.pending).toList();
    final accepted = reservations.where((r) => r.status == ReservationStatus.accepted).toList();

    if (pending.isEmpty && accepted.isEmpty) {
      return const Center(child: Text('Aucune réservation en cours', style: TextStyle(color: Colors.grey)));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pending.isNotEmpty) ...[
            Row(children: [const Icon(Icons.hourglass_empty, size: 16, color: Colors.orange), const SizedBox(width: 4), Text('En attente (${pending.length})', style: const TextStyle(fontWeight: FontWeight.bold))]),
            const SizedBox(height: 12),
            ...pending.map((r) => _buildReservationCard(r)),
            const SizedBox(height: 24),
          ],
          if (accepted.isNotEmpty) ...[
            Row(children: [const Icon(Icons.check_circle, color: Colors.green, size: 16), const SizedBox(width: 4), Text('Confirmées (${accepted.length})', style: const TextStyle(fontWeight: FontWeight.bold))]),
            const SizedBox(height: 12),
            ...accepted.map((r) => _buildReservationCard(r)),
          ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // ==================== HISTORIQUE (Correction principale) ====================
  Widget _buildHistorique(List<Reservation> reservations) {
    // On met dans l'historique : completed + rejected + cancelled + accepted (pour laisser un avis)
    var history = reservations.where((r) =>
      r.status == ReservationStatus.completed ||
      r.status == ReservationStatus.rejected ||
      r.status == ReservationStatus.cancelled ||
      r.status == ReservationStatus.accepted
    ).toList();

    // Filtre de recherche
    if (_searchQuery.isNotEmpty) {
      history = history.where((r) {
        final query = _searchQuery.toLowerCase();
        return r.itemTitle.toLowerCase().contains(query) || r.ownerName.toLowerCase().contains(query);
      }).toList();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
            decoration: InputDecoration(
              hintText: 'Rechercher par objet ou propriétaire...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _searchController.clear();
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (history.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Column(
                  children: [
                    const Icon(Icons.history, size: 60, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isNotEmpty ? 'Aucun résultat pour "$_searchQuery"' : 'Aucune réservation dans l\'historique',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            Row(children: [
              const Icon(Icons.history, color: Colors.grey, size: 16),
              const SizedBox(width: 4),
              Text('Historique (${history.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 12),
            ...history.map((r) => _buildHistoryCard(r)),
          ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // ==================== CARD EN COURS ====================
  Widget _buildReservationCard(Reservation reservation) {
    Color statusColor = Colors.orange;
    String statusText = 'En attente';
    if (reservation.status == ReservationStatus.accepted) {
      statusColor = Colors.green;
      statusText = 'Confirmée ✅';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildItemImage(reservation.itemImage),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reservation.itemTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Row(children: [const Icon(Icons.person, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(reservation.ownerName, style: TextStyle(color: Colors.grey.shade600))]),
                const SizedBox(height: 4),
                Row(children: [const Icon(Icons.calendar_today, size: 14, color: Colors.grey), const SizedBox(width: 4), Text('${_formatDate(reservation.startDate)} → ${_formatDate(reservation.endDate)}', style: const TextStyle(fontSize: 12, color: Colors.grey))]),
                const SizedBox(height: 4),
                Row(children: [const Icon(Icons.euro, size: 14, color: Colors.grey), const SizedBox(width: 4), Text('${reservation.totalPrice.toStringAsFixed(0)}€', style: const TextStyle(fontWeight: FontWeight.w500))]),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)),
                  child: Text(statusText, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== CARD HISTORIQUE ====================
  Widget _buildHistoryCard(Reservation reservation) {
    // Tu peux améliorer les couleurs selon le statut si tu veux
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildItemImage(reservation.itemImage),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reservation.itemTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Row(children: [const Icon(Icons.person, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(reservation.ownerName, style: TextStyle(color: Colors.grey.shade600))]),
                    const SizedBox(height: 4),
                    Row(children: [const Icon(Icons.calendar_today, size: 14, color: Colors.grey), const SizedBox(width: 4), Text('${_formatDate(reservation.startDate)} → ${_formatDate(reservation.endDate)}', style: const TextStyle(fontSize: 12, color: Colors.grey))]),
                    const SizedBox(height: 4),
                    Row(children: [const Icon(Icons.euro, size: 14, color: Colors.grey), const SizedBox(width: 4), Text('${reservation.totalPrice.toStringAsFixed(0)}€', style: const TextStyle(fontWeight: FontWeight.w500))]),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final item = Item(
                  id: reservation.itemId,
                  image: reservation.itemImage,
                  title: reservation.itemTitle,
                  description: '',
                  owner: reservation.ownerName,
                  ownerId: reservation.ownerId,
                  ownerRating: 0.0,
                  memberSince: '',
                  category: '',
                  isAvailable: true,
                  rating: 0.0,
                  location: '',
                  price: reservation.totalPrice,
                  createdAt: DateTime.now(),
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LeaveReviewPage(item: item)),
                );
              },
              icon: const Icon(Icons.star, size: 16, color: Colors.white),
              label: const Text('Laisser un avis'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== IMAGE HANDLER ====================
  Widget _buildItemImage(String? imagePath) {
    if (imagePath == null || imagePath.trim().isEmpty) return _buildPlaceholder();

    if (imagePath.startsWith('assets/')) {
      return Image.asset(imagePath, width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildPlaceholder());
    }

    try {
      String cleanBase64 = imagePath.contains(',') ? imagePath.split(',').last : imagePath;
      final bytes = base64Decode(cleanBase64);
      return Image.memory(bytes, width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildPlaceholder());
    } catch (e) {
      return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
      child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 32),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}