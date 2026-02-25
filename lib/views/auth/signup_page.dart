import 'package:flutter/material.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import 'login_page.dart';

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
  
  String selectedRole = 'Propriétaire'; // Par défaut

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            SizedBox(height: 60),
            // Logo
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Color(0xFF6B4EFF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.sync_alt,
                color: Colors.white,
                size: 40,
              ),
            ),
            SizedBox(height: 20),
            // Titre
            Text(
              'Sign Up',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            // Full Name
            CustomTextField(
              hintText: 'Full Name',
              prefixIcon: Icons.person_outline,
              controller: nameController,
            ),
            SizedBox(height: 16),
            // Email
            CustomTextField(
              hintText: 'Email Address',
              prefixIcon: Icons.email_outlined,
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            // Téléphone
            CustomTextField(
              hintText: 'Numéro de téléphone',
              prefixIcon: Icons.phone_outlined,
              controller: phoneController,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),
            // Password
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
            // Bouton Sign up
            CustomButton(
              text: 'Sing up',
              onPressed: () {
                // TODO: Implémenter l'inscription
              },
            ),
            SizedBox(height: 16),
            // Bouton Login
            CustomButton(
              text: 'Login',
              isOutlined: true,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 20),
            // Lien bas
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: TextStyle(color: Colors.grey),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
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
      children :[
         Radio<String>(
          value: role,
          groupValue: selectedRole,
          onChanged: (value) {
            setState(() {
              selectedRole = value!;
            });
          },
          activeColor: Color(0xFF6B4EFF),
        ),
        Text(role),
      ],
    );
  }
}