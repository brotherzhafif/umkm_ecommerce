import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  String error = '';

  @override
  void initState() {
    super.initState();
    // Lock orientation to portrait when entering login page
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    // Restore all orientations when leaving login page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    });
    super.dispose();
  }

  Future<void> login() async {
    // Validate inputs first
    if (emailController.text.isEmpty) {
      setState(() => error = 'Email tidak boleh kosong');
      return;
    }

    if (!emailController.text.contains('@')) {
      setState(() => error = 'Email tidak valid');
      return;
    }

    if (passwordController.text.isEmpty) {
      setState(() => error = 'Password tidak boleh kosong');
      return;
    }

    setState(() => loading = true);
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      final uid = cred.user!.uid;

      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final role = userDoc.data()?['role'] ?? 'customer';

      if (!mounted) return;
      if (role == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin');
      } else {
        Navigator.pushReplacementNamed(context, '/customer');
      }
    } catch (e) {
      String errorMsg = 'Login gagal';
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            errorMsg = 'Email tidak terdaftar';
            break;
          case 'wrong-password':
            errorMsg = 'Password salah';
            break;
          case 'invalid-email':
            errorMsg = 'Format email tidak valid';
            break;
          case 'user-disabled':
            errorMsg = 'Akun telah dinonaktifkan';
            break;
          default:
            errorMsg = 'Login gagal: ${e.code}';
        }
      } else {
        errorMsg = 'Login gagal: ${e.toString()}';
      }
      setState(() => error = errorMsg);
    } finally {
      setState(() => loading = false);
    }
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/icon.png',
                          width: 48,
                          height: 48,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Masukkan email anda',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        prefixIcon: const Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email tidak boleh kosong';
                        }
                        if (!value.contains('@')) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Masukkan password anda',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        prefixIcon: const Icon(Icons.lock),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    if (error.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                error,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed:
                            loading
                                ? null
                                : () {
                                  if (_formKey.currentState!.validate()) {
                                    login();
                                  }
                                },
                        child:
                            loading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text(
                                  "Login",
                                  style: TextStyle(color: Colors.white),
                                ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/register'),
                      child: const Text(
                        "Belum punya akun? Daftar disini",
                        style: TextStyle(
                          color: Colors.lightBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
