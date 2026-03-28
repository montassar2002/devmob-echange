import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/item.dart';
import '../../models/reservation.dart';
import '../../services/reservation_service.dart';
import '../../providers/auth_provider.dart' as appProvider;
import '../../widgets/custom_button.dart';

class ReservationPage extends StatefulWidget {
  final Item item;

  const ReservationPage({
    super.key,
    required this.item,
  });

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  DateTime startDate = DateTime.now().add(Duration(days: 1));
  DateTime endDate = DateTime.now().add(Duration(days: 4));
  bool acceptConditions = false;
  bool _isLoading = false;
  final ReservationService _reservationService = ReservationService();

  int get numberOfDays => endDate.difference(startDate).inDays;
  double get totalLocation => numberOfDays * widget.item.price;
  double get caution => 100.0;
  double get total => totalLocation + caution;

  // Afficher image selon le type Base64 ou Asset
  Widget _buildImage(String imageUrl,
      {double width = 80, double height = 80}) {
    if (imageUrl.startsWith('data:image')) {
      try {
        final base64Data = imageUrl.split(',')[1];
        return Image.memory(
          base64Decode(base64Data),
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: width,
            height: height,
            color: Colors.grey.shade200,
            child: Icon(Icons.image, color: Colors.grey),
          ),
        );
      } catch (e) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          child: Icon(Icons.image, color: Colors.grey),
        );
      }
    } else {
      return Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          child: Icon(Icons.image, color: Colors.grey),
        ),
      );
    }
  }

  Future<void> _selectDate(bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? startDate : endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2027),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
          if (startDate.isAfter(endDate)) {
            endDate = startDate.add(Duration(days: 1));
          }
        } else {
          endDate = picked;
        }
      });
    }
  }

  Future<void> _sendReservation() async {
    final authProvider = Provider.of<appProvider.AuthProvider>(
      context, listen: false
    );

    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vous devez être connecté !')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Récupérer ownerId depuis Firestore si vide
      String ownerId = widget.item.ownerId;

      if (ownerId.isEmpty) {
        final itemDoc = await FirebaseFirestore.instance
            .collection('items')
            .doc(widget.item.id)
            .get();
        if (itemDoc.exists) {
          ownerId = itemDoc.data()?['ownerId'] ?? '';
        }
      }

      // Empêcher propriétaire de réserver son propre objet
      if (ownerId == authProvider.currentUser!.id) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Vous ne pouvez pas réserver votre propre objet !'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      final reservation = Reservation(
        id: '',
        itemId: widget.item.id,
        itemTitle: widget.item.title,
        itemImage: widget.item.image, // ← image Base64 ou asset
        renterId: authProvider.currentUser!.id,
        renterName: authProvider.currentUser!.name,
        ownerId: ownerId,
        ownerName: widget.item.owner,
        startDate: startDate,
        endDate: endDate,
        totalPrice: total,
        status: ReservationStatus.pending,
        createdAt: DateTime.now(),
      );

      await _reservationService.createReservation(reservation);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Demande envoyée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
          'Réserver',
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
            // Objet sélectionné - IMAGE CORRIGÉE
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildImage(
                    widget.item.image,
                    width: 80,
                    height: 80,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.item.price.toStringAsFixed(0)}€/jour',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Dates
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'Dates de location',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            GestureDetector(
              onTap: () => _selectDate(true),
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Du: ${_formatDate(startDate)}'),
              ),
            ),
            SizedBox(height: 8),
            GestureDetector(
              onTap: () => _selectDate(false),
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Au: ${_formatDate(endDate)}'),
              ),
            ),
            SizedBox(height: 24),

            // Récapitulatif
            Row(
              children: [
                Icon(Icons.receipt_outlined,
                    size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'Récapitulatif',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Location ($numberOfDays j × ${widget.item.price.toStringAsFixed(0)}€)',
                      ),
                      Text('${totalLocation.toStringAsFixed(0)}€'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Caution'),
                      Text('${caution.toStringAsFixed(0)}€'),
                    ],
                  ),
                  Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total à payer',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${total.toStringAsFixed(0)}€',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Conditions
            Row(
              children: [
                Checkbox(
                  value: acceptConditions,
                  onChanged: (value) {
                    setState(() {
                      acceptConditions = value ?? false;
                    });
                  },
                  activeColor: Color(0xFF6B4EFF),
                ),
                Expanded(
                  child: Text(
                    'J\'accepte les conditions de location',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Bouton Envoyer
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : CustomButton(
                    text: 'Envoyer la demande',
                    onPressed:
                        acceptConditions ? _sendReservation : () {},
                    backgroundColor: acceptConditions
                        ? Color(0xFF2196F3)
                        : Colors.grey,
                  ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}