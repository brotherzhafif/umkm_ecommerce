import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final roleOptions = ['admin', 'customer'];
  String selectedRole = 'customer';
  String error = '';
  bool loading = false;

  Future<void> register() async {
    setState(() => loading = true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({'email': emailController.text, 'role': selectedRole});

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      setState(() => error = 'Gagal daftar: ${e.toString()}');
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Register", style: TextStyle(fontSize: 28)),
                const SizedBox(height: 24),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 16),
                DropdownButton<String>(
                  value: selectedRole,
                  onChanged: (val) => setState(() => selectedRole = val!),
                  items:
                      roleOptions
                          .map(
                            (r) => DropdownMenuItem(value: r, child: Text(r)),
                          )
                          .toList(),
                ),
                const SizedBox(height: 24),
                if (error.isNotEmpty)
                  Text(error, style: const TextStyle(color: Colors.red)),
                ElevatedButton(
                  onPressed: register,
                  child:
                      loading
                          ? const CircularProgressIndicator()
                          : const Text("Daftar"),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                  child: const Text("Sudah punya akun? Login di sini"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
