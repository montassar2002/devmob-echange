import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../../models/item.dart';
import '../../services/item_service.dart';
import '../../providers/auth_provider.dart' as appProvider;
import '../../widgets/custom_button.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController(text: '15');
  final _cautionController = TextEditingController(text: '100');
  final _locationController = TextEditingController();
  final ItemService _itemService = ItemService();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  File? _selectedImage;
  String? _base64Image;

  String _selectedCategory = 'Outils';
  final List<String> _categories = [
    'Outils', 'Sport', 'Tech', 'Maison', 'Loisirs',
  ];

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      maxHeight: 600,
      imageQuality: 70, // Réduire la qualité pour réduire la taille
    );
    if (image != null) {
      final file = File(image.path);
      final bytes = await file.readAsBytes();
      final base64 = base64Encode(bytes);
      
      setState(() {
        _selectedImage = file;
        _base64Image = base64;
      });
      
      print('✅ Image sélectionnée, taille Base64: ${base64.length} chars');
    }
  }

  Future<void> _addItem() async {
    if (!_formKey.currentState!.validate()) return;

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
      // Utiliser Base64 si image sélectionnée, sinon image par défaut selon catégorie
      String imageToSave;
      
      if (_base64Image != null) {
        // Image depuis la galerie en Base64
        imageToSave = 'data:image/jpeg;base64,$_base64Image';
      } else {
        // Image par défaut selon la catégorie
        switch (_selectedCategory) {
          case 'Sport':
            imageToSave = 'assets/images/velo.png';
            break;
          case 'Camping':
            imageToSave = 'assets/images/tente.png';
            break;
          default:
            imageToSave = 'assets/images/perceuse.png';
        }
      }

      final item = Item(
        id: '',
        image: imageToSave,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        price: double.tryParse(_priceController.text) ?? 0.0,
        location: _locationController.text.trim(),
        isAvailable: true,
        rating: 0.0,
        owner: authProvider.currentUser!.name,
        ownerId: authProvider.currentUser!.id,
        ownerRating: 0.0,
        memberSince: DateTime.now().year.toString(),
        distance: null,
        createdAt: DateTime.now(),
      );

      await _itemService.addItem(item);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Objet ajouté avec succès ! ✅'),
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
          'Ajouter un objet',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Section Photo - UNE SEULE PHOTO
              _buildLabel('Photo de l\'objet'),
              SizedBox(height: 12),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedImage != null
                          ? Color(0xFF2196F3)
                          : Colors.grey.shade300,
                      width: _selectedImage != null ? 2 : 1,
                    ),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 60,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Appuyez pour ajouter une photo',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Depuis votre galerie',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              if (_selectedImage != null)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: Color(0xFF2196F3), size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Photo sélectionnée ✅',
                        style: TextStyle(
                          color: Color(0xFF2196F3),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedImage = null;
                            _base64Image = null;
                          });
                        },
                        child: Text(
                          'Supprimer',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 20),

              // Titre
              _buildLabel('Titre', required: true),
              SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration('Ex: Perceuse Bosch...'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Catégorie
              _buildLabel('Catégorie', required: true),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() => _selectedCategory = newValue!);
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Description
              _buildLabel('Description', required: true),
              SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: _inputDecoration(
                    'Décrivez votre objet en détail...'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Tarif journalier
              _buildLabel('Tarif journalier (€)', required: true),
              SizedBox(height: 8),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('15'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un prix';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Nombre invalide';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Caution
              _buildLabel('Caution (€)'),
              SizedBox(height: 8),
              TextFormField(
                controller: _cautionController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('100'),
              ),
              SizedBox(height: 16),

              // Localisation
              _buildLabel('Localisation', required: true),
              SizedBox(height: 8),
              TextFormField(
                controller: _locationController,
                decoration: _inputDecoration('Ex: Paris 11ème...'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une localisation';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),

              // Bouton Ajouter
              _isLoading
                  ? Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 8),
                          Text(
                            'Ajout en cours...',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : CustomButton(
                      text: 'Ajouter l\'objet',
                      onPressed: _addItem,
                    ),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        children: [
          TextSpan(text: text),
          if (required)
            TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding:
          EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _cautionController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}