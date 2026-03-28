import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../models/item.dart';
import '../../providers/auth_provider.dart' as appProvider;
import '../../widgets/custom_button.dart';

class LeaveReviewPage extends StatefulWidget {
  final Item item;

  const LeaveReviewPage({
    super.key,
    required this.item,
  });

  @override
  State<LeaveReviewPage> createState() => _LeaveReviewPageState();
}

class _LeaveReviewPageState extends State<LeaveReviewPage> {
  double _rating = 0;
  final _commentController = TextEditingController();
  bool _isLoading = false;

  // Afficher image Base64 ou Asset
  Widget _buildImage(String imageUrl) {
    if (imageUrl.startsWith('data:image')) {
      try {
        final base64Data = imageUrl.split(',')[1];
        return Image.memory(
          base64Decode(base64Data),
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.image, color: Colors.grey, size: 40),
        );
      } catch (e) {
        return Icon(Icons.image, color: Colors.grey, size: 40);
      }
    } else {
      return Image.asset(
        imageUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.image, color: Colors.grey, size: 40),
      );
    }
  }

  // Sauvegarder l'avis dans Firestore
  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez donner une note !'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

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
      // Sauvegarder dans Firestore collection "reviews"
      await FirebaseFirestore.instance.collection('reviews').add({
        'itemId': widget.item.id,
        'itemTitle': widget.item.title,
        'ownerId': widget.item.ownerId,
        'ownerName': widget.item.owner,
        'renterId': authProvider.currentUser!.id,
        'renterName': authProvider.currentUser!.name,
        'rating': _rating,
        'comment': _commentController.text.trim(),
        'createdAt': DateTime.now(),
      });

      print('✅ Avis sauvegardé dans Firestore !');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Avis envoyé avec succès ! ⭐'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('❌ Erreur sauvegarde avis : $e');
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
          'Laisser un avis',
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
            // Objet évalué
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildImage(widget.item.image), // ← CORRIGÉ
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Loué à ${widget.item.owner}',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),

            // Note
            Text(
              'Votre note',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),
            SizedBox(height: 8),
            Center(
              child: Text(
                _rating > 0
                    ? '${_rating.toInt()}/5 ⭐'
                    : 'Appuyez pour noter',
                style: TextStyle(
                  color: _rating > 0 ? Colors.amber : Colors.grey,
                  fontSize: 16,
                  fontWeight: _rating > 0
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
            SizedBox(height: 32),

            // Commentaire
            Text(
              'Votre commentaire',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _commentController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText:
                    'Décrivez votre expérience avec cet objet...',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.all(16),
              ),
            ),
            SizedBox(height: 32),

            // Bouton envoyer
            _isLoading
                ? Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text('Envoi en cours...',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : CustomButton(
                    text: 'Envoyer l\'avis',
                    onPressed: _rating > 0 ? _submitReview : () {},
                    backgroundColor: _rating > 0
                        ? Color(0xFF2196F3)
                        : Colors.grey,
                  ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}