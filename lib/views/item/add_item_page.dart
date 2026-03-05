import 'package:flutter/material.dart';
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

  String _selectedCategory = 'Outil de bricolage';
  
  final List<String> _categories = [
    'Outil de bricolage',
    'Sport',
    'Tech',
    'Maison',
    'Loisirs',
  ];

  final List<String> _photos = [
    'assets/images/perceuse.png',
    'assets/images/perceuse.png',
    'assets/images/perceuse.png',
    'assets/images/perceuse.png',
  ];

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
              // Photos
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _photos.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _photos.length) {
                      // Bouton ajouter photo
                      return GestureDetector(
                        onTap: () {
                          // TODO: Ajouter une photo
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          margin: EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Icon(Icons.add, color: Colors.grey),
                        ),
                      );
                    }
                    return Container(
                      width: 80,
                      height: 80,
                      margin: EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: AssetImage(_photos[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              
              // Titre
              _buildLabel('Titre', required: true),
              SizedBox(height: 8),
              _buildTextField(
                controller: _titleController,
                hintText: 'Perceuse Bosch...',
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
                      setState(() {
                        _selectedCategory = newValue!;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),
              
              // Description
              _buildLabel('Description', required: true),
              SizedBox(height: 8),
              _buildTextField(
                controller: _descriptionController,
                hintText: 'Perceuse professionnelle idéale pour tous travaux...',
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              // Tarif journalier
              _buildLabel('Tarif journalier (€)'),
              SizedBox(height: 8),
              _buildNumberField(
                controller: _priceController,
                hintText: '15',
              ),
              SizedBox(height: 16),
              
              // Caution
              _buildLabel('Caution (€)'),
              SizedBox(height: 8),
              _buildNumberField(
                controller: _cautionController,
                hintText: '100',
              ),
              SizedBox(height: 16),
              
              // Localisation
              _buildLabel('Localisation'),
              SizedBox(height: 8),
              _buildTextField(
                controller: _locationController,
                hintText: 'Paris 11ème...',
              ),
              SizedBox(height: 32),
              
              // Bouton Ajouter
              CustomButton(
                text: 'Ajouter l\'objet',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // TODO: Sauvegarder l'objet
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Objet ajouté avec succès !'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.arrow_drop_up, size: 16, color: Colors.grey),
            Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey),
          ],
        ),
      ),
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