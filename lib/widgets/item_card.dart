import 'package:flutter/material.dart';
import '../models/item.dart';
import '../views/item/item_detail_page.dart';

class ItemCard extends StatelessWidget {
  final Item item;

  const ItemCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
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
            // Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                height: 120,
                width: double.infinity,
                color: Colors.grey.shade100,
                child: Center(
                  child: Image.asset(
                    item.image,
                    height: 100,
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
                          item.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        item.isAvailable ? '✅ DISPO' : '🔴 RÉSERVÉ',
                        style: TextStyle(
                          color: item.isAvailable ? Colors.green : Colors.red,
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
                        '${item.rating}',
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
                        item.location,
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
                        '\$${item.price}/Jour',
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
      ),
    );
  }
}