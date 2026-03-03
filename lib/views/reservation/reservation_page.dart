import 'package:flutter/material.dart';
import '../../models/item.dart';
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
  DateTime startDate = DateTime(2025, 2, 15);
  DateTime endDate = DateTime(2025, 2, 18);
  bool acceptConditions = false;

  int get numberOfDays {
    return endDate.difference(startDate).inDays;
  }

  double get totalLocation {
    return numberOfDays * widget.item.price;
  }

  double get caution {
    return 100.0; // Caution fixe
  }

  double get total {
    return totalLocation + caution;
  }

  Future<void> _selectDate(bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? startDate : endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
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
            // Objet sélectionné
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    widget.item.image,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
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
                      SizedBox(height: 4),
                      Text(
                        '${widget.item.price.toStringAsFixed(0)}€/jour',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            
            // Dates de location
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
            // Date début
            GestureDetector(
              onTap: () => _selectDate(true),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Du: ${_formatDate(startDate)}',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8),
            // Date fin
            GestureDetector(
              onTap: () => _selectDate(false),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Au: ${_formatDate(endDate)}',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            
            // Récapitulatif
            Row(
              children: [
                Icon(Icons.receipt_outlined, size: 16, color: Colors.grey),
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
                      Text('Location ($numberOfDays j × ${widget.item.price.toStringAsFixed(0)}€)'),
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
                Icon(Icons.description_outlined, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'Conditions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text('• Remise en main propre requise'),
            Text('• Caution remboursée après retour'),
            SizedBox(height: 16),
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
            CustomButton(
              text: 'Envoyer la demande',
              onPressed: acceptConditions
                  ? () {
                      // TODO: Envoyer la demande de réservation
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Demande envoyée !'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  : () {}, // Désactivé si conditions non acceptées
              backgroundColor: acceptConditions ? Color(0xFF2196F3) : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}