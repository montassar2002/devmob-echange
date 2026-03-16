import 'package:flutter/material.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart' as app;
import '../home/home_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  String selectedRole = 'Propriétaire';
  bool _isLoading = false;

  Future<void> _signUp() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final role = selectedRole == 'Propriétaire'
          ? app.UserRole.owner
          : app.UserRole.renter;

      final user = await _authService.signUp(
        name: nameController.text,
        email: emailController.text,
        phone: phoneController.text,
        password: passwordController.text,
        role: role,
      );

      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            SizedBox(height: 60),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Color(0xFF6B4EFF),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.sync_alt, color: Colors.white, size: 40),
            ),
            SizedBox(height: 20),
            Text(
              'Sign Up',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            CustomTextField(
              hintText: 'Full Name',
              prefixIcon: Icons.person_outline,
              controller: nameController,
            ),
            SizedBox(height: 16),
            CustomTextField(
              hintText: 'Email Address',
              prefixIcon: Icons.email_outlined,
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            CustomTextField(
              hintText: 'Numéro de téléphone',
              prefixIcon: Icons.phone_outlined,
              controller: phoneController,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),
            CustomTextField(
              hintText: 'Password',
              prefixIcon: Icons.lock_outline,
              isPassword: true,
              controller: passwordController,
            ),
            SizedBox(height: 20),
            // Choix du rôle
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildRoleRadio('Propriétaire'),
                SizedBox(width: 30),
                _buildRoleRadio('Locataire'),
              ],
            ),
            SizedBox(height: 30),
            _isLoading
                ? CircularProgressIndicator(color: Color(0xFF6B4EFF))
                : CustomButton(
                    text: 'Sign up',
                    onPressed: _signUp,
                  ),
            SizedBox(height: 16),
            CustomButton(
              text: 'Login',
              isOutlined: true,
              onPressed: () => Navigator.pop(context),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Already have an account? ', style: TextStyle(color: Colors.grey)),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: Color(0xFF6B4EFF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleRadio(String role) {
    return Row(
      children: [
        Radio<String>(
          value: role,
          groupValue: selectedRole,
          onChanged: (value) {
            if (value != null) {
              setState(() => selectedRole = value);
            }
          },
          activeColor: Color(0xFF6B4EFF),
        ),
        Text(role),
      ],
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}