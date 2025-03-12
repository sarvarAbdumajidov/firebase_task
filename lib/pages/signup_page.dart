import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_task/pages/verified_page.dart';
import 'package:firebase_task/service/log_service.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  static const String id = '/signup';

  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  Future<void> _signUp() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Firebase orqali ro‘yxatdan o‘tkazish
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user != null) {
        await user.sendEmailVerification(); // Email yuborish
        LogService.i("✅ Email tasdiqlash linki yuborildi!");

        Navigator.pushNamed(
          context,
          VerifiedPage.id,
          arguments: {
            'name': name,
            'email': email,
            'password': password,
          },
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Ro‘yxatdan o‘tishda xatolik yuz berdi.";
      if (e.code == 'email-already-in-use') {
        errorMessage = "Bu email allaqachon ro‘yxatdan o‘tgan.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Email formati noto‘g‘ri!";
      } else if (e.code == 'weak-password') {
        errorMessage = "Parol juda oddiy. Kuchliroq parol tanlang!";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: true,
          title: Text('Sign Up', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.deepOrange,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.name,
                      controller: _nameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Name",
                        label: Text('Name'),
                      ),
                      validator: (value) =>
                      value!.isEmpty ? 'Ismni kiriting!' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Email",
                        label: Text('Email'),
                      ),
                      validator: (value) =>
                      value!.isEmpty ? 'Emailni kiriting!' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      keyboardType: TextInputType.visiblePassword,
                      controller: _passwordController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Password",
                        label: Text('Password'),
                      ),
                      validator: (value) =>
                      value!.length < 6 ? 'Kamida 6 ta belgi bo‘lishi kerak!' : null,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: MaterialButton(
                        color: Colors.deepOrangeAccent,
                        onPressed: _signUp,
                        child: Text('Sign Up', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
                isLoading ? Center(child: CircularProgressIndicator()) : SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
