import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/item.dart';
import '../../widgets/custom_button.dart';
import '../../providers/auth_provider.dart' as appProvider;
import '../reservation/reservation_page.dart';

class ItemDetailPage extends StatefulWidget {
  final Item item;

  const ItemDetailPage({
    super.key,
    required this.item,
  });

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  bool isExpanded = false;

  // Afficher image selon le type (Base64 ou Asset)
  Widget _buildImage(String imageUrl, {double height = 200}) {
    if (imageUrl.startsWith('data:image')) {
      try {
        final base64Data = imageUrl.split(',')[1];
        return Image.memory(
          base64Decode(base64Data),
          height: height,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.image, color: Colors.grey, size: 80),
        );
      } catch (e) {
        return Icon(Icons.image, color: Colors.grey, size: 80);
      }
    } else {
      return Image.asset(
        imageUrl,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.image, color: Colors.grey, size: 80),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<appProvider.AuthProvider>(
      context, listen: false
    );
    final isOwner = authProvider.isOwner;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Produit Détails',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image principale - CORRIGÉ Base64 + Asset
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: _buildImage(widget.item.image, height: 200),
              ),
            ),
            SizedBox(height: 20),

            // Titre
            Text(
              widget.item.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),

            // Infos propriétaire
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey.shade300,
                  child: Icon(Icons.person, size: 20, color: Colors.grey),
                ),
                SizedBox(width: 8),
                Text(
                  widget.item.owner,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                SizedBox(width: 8),
                Icon(Icons.star, color: Colors.orange, size: 16),
                Text(
                  ' ${widget.item.ownerRating}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                Text(
                  'Membre depuis ${widget.item.memberSince}',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            SizedBox(height: 8),

            // Localisation
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.red, size: 16),
                Text(
                  ' ${widget.item.location}${widget.item.distance != null ? ' · À ${widget.item.distance}' : ''}',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Prix
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: Color(0xFF2196F3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${widget.item.price.toStringAsFixed(0)}€ / jour',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),

            // Description
            Text(
              '📝 Description',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() => isExpanded = !isExpanded),
              child: Text(
                widget.item.description,
                style: TextStyle(color: Colors.grey.shade700, height: 1.5),
                maxLines: isExpanded ? null : 3,
                overflow: isExpanded ? null : TextOverflow.ellipsis,
              ),
            ),
            Text(
              isExpanded ? ' Lire moins' : ' Lire plus',
              style: TextStyle(
                color: Color(0xFF6B4EFF),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),

            // Caractéristiques
            Text(
              '📋 Caractéristiques',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            _buildCharacteristic('Catégorie', widget.item.category),
            _buildCharacteristic(
              'État',
              widget.item.isAvailable ? 'Comme neuf ✨' : 'Bon état',
            ),
            _buildCharacteristic('Localisation', widget.item.location),
            SizedBox(height: 20),

            // Calendrier
            Text(
              '📅 Disponibilités',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTimeSelector('10:30', true),
                      Text('→', style: TextStyle(fontSize: 20)),
                      _buildTimeSelector('05:30 pm', false),
                    ],
                  ),
                  SizedBox(height: 16),
                  _buildCalendarPreview(),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          child: Text('Cancel'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            side: BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          child: Text('Done'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 80),
          ],
        ),
      ),

      // Bouton Réserver
      bottomNavigationBar: isOwner
          ? SizedBox(height: 0)
          : Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 4,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: CustomButton(
                text: 'Réserver Cet Objet',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ReservationPage(item: widget.item),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildCharacteristic(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('• $label: ', style: TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildTimeSelector(String time, bool isStart) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isStart ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(
            isStart ? Icons.access_time : Icons.access_time_filled,
            size: 16,
            color: isStart ? Colors.white : Colors.black,
          ),
          SizedBox(width: 4),
          Text(
            time,
            style: TextStyle(
              color: isStart ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarPreview() {
    final now = DateTime.now();
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final List<String> months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final dates = List.generate(daysInMonth, (index) => index + 1);

    return Column(
      children: [
        Text(
          '${months[now.month - 1]} ${now.year}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: days
              .map((day) => Text(day,
                  style: TextStyle(fontSize: 10, color: Colors.grey)))
              .toList(),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: dates.map((date) {
            final isToday = date == now.day;
            return Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isToday ? Colors.black : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$date',
                  style: TextStyle(
                    color: isToday ? Colors.white : Colors.black,
                    fontWeight:
                        isToday ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}