import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/item.dart';
import '../../services/item_service.dart';
import '../../widgets/custom_button.dart';

class EditItemPage extends StatefulWidget {
  final Item item;

  const EditItemPage({super.key, required this.item});

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _locationController;
  final ItemService _itemService = ItemService();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  File? _newImage;
  String? _newBase64Image;
  late String _selectedCategory;

  final List<String> _categories = [
    'Outils', 'Sport', 'Tech', 'Maison', 'Loisirs',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item.title);
    _descriptionController =
        TextEditingController(text: widget.item.description);
    _priceController =
        TextEditingController(text: widget.item.price.toString());
    _locationController =
        TextEditingController(text: widget.item.location);
    _selectedCategory = widget.item.category;
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      maxHeight: 600,
      imageQuality: 70,
    );
    if (image != null) {
      final file = File(image.path);
      final bytes = await file.readAsBytes();
      setState(() {
        _newImage = file;
        _newBase64Image = base64Encode(bytes);
      });
    }
  }

  Widget _buildCurrentImage() {
    if (_newImage != null) {
      return Image.file(_newImage!, height: 150, fit: BoxFit.contain);
    } else if (widget.item.image.startsWith('data:image')) {
      final base64Data = widget.item.image.split(',')[1];
      return Image.memory(
        base64Decode(base64Data),
        height: 150,
        fit: BoxFit.contain,
      );
    } else {
      return Image.asset(
        widget.item.image,
        height: 150,
        fit: BoxFit.contain,
      );
    }
  }

  Future<void> _updateItem() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final imageToSave = _newBase64Image != null
          ? 'data:image/jpeg;base64,$_newBase64Image'
          : widget.item.image;

      final updatedItem = Item(
        id: widget.item.id,
        image: imageToSave,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        price: double.tryParse(_priceController.text) ?? 0.0,
        location: _locationController.text.trim(),
        isAvailable: widget.item.isAvailable,
        rating: widget.item.rating,
        owner: widget.item.owner,
        ownerId: widget.item.ownerId,
        ownerRating: widget.item.ownerRating,
        memberSince: widget.item.memberSince,
        distance: widget.item.distance,
        createdAt: widget.item.createdAt,
      );

      await _itemService.updateItem(updatedItem);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Objet modifié avec succès ! ✅'),
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
          'Modifier l\'objet',
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
              // Photo actuelle
              _buildLabel('Photo'),
              SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Center(child: _buildCurrentImage()),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Appuyez pour changer la photo',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              SizedBox(height: 16),

              // Titre
              _buildLabel('Titre', required: true),
              SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration('Titre'),
                validator: (value) => value!.isEmpty ? 'Requis' : null,
              ),
              SizedBox(height: 16),

              // Catégorie
              _buildLabel('Catégorie'),
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
                decoration: _inputDecoration('Description'),
                validator: (value) => value!.isEmpty ? 'Requis' : null,
              ),
              SizedBox(height: 16),

              // Prix
              _buildLabel('Prix (€/jour)', required: true),
              SizedBox(height: 8),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Prix'),
                validator: (value) => value!.isEmpty ? 'Requis' : null,
              ),
              SizedBox(height: 16),

              // Localisation
              _buildLabel('Localisation', required: true),
              SizedBox(height: 8),
              TextFormField(
                controller: _locationController,
                decoration: _inputDecoration('Localisation'),
                validator: (value) => value!.isEmpty ? 'Requis' : null,
              ),
              SizedBox(height: 32),

              // Bouton Modifier
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : CustomButton(
                      text: 'Enregistrer les modifications',
                      onPressed: _updateItem,
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
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}