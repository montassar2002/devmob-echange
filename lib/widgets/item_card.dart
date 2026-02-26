import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  final String image;
  final String title;
  final bool isAvailable;
  final double rating;
  final String location;
  final double price;

  const ItemCard({
    super.key,
    required this.image,
    required this.title,
    required this.isAvailable,
    required this.rating,
    required this.location,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: EdgeInsets.only(right: 12),
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
          // Image - MODIFIÉ : Image.asset au lieu de Image.network
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              height: 120,
              width: double.infinity,
              color: Colors.grey.shade100, // Fond gris clair
              child: Center(
                child: Image.asset(
                  image,
                  height: 100, // Hauteur max de l'image
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
                // Titre et statut
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      isAvailable ? '✅ DISPO' : '🔴 RÉSERVÉ',
                      style: TextStyle(
                        color: isAvailable ? Colors.green : Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                // Note
                Row(
                  children: [
                    Text(
                      '$rating',
                      style: TextStyle(fontSize: 12),
                    ),
                    Icon(Icons.star, color: Colors.orange, size: 12),
                  ],
                ),
                SizedBox(height: 4),
                // Localisation
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                    SizedBox(width: 2),
                    Text(
                      location,
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                // Prix
                Row(
                  children: [
                    Icon(Icons.attach_money, size: 12, color: Colors.grey),
                    Text(
                      '\$$price/Jour',
                      style: TextStyle(
                        fontSize: 12,
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
    );
  }
}