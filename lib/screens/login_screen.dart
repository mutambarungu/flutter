import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  void _loadSavedEmail() async {
    final savedCredentials = await AuthService().getUserCredentials();
    setState(() {
      _emailController.text = savedCredentials['email'] ?? "";
      _rememberMe = savedCredentials['rememberMe'] as bool? ?? false;
    });
  }

  void _login(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool isSuccess = await authProvider.login(
        _emailController.text,
        _passwordController.text,
      );

      if (isSuccess) {
        print("Login successful!");
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() => _errorMessage = "Invalid email or password!");
      }
    } catch (error) {
      setState(() => _errorMessage = "Something went wrong. Try again.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',  
              fit: BoxFit.cover,
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 8,
                color: Colors.white.withOpacity(0.9),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // App Logo
                        Image.asset(
                          'assets/images/logoexpense1.png',  
                          height: 80,
                        ),
                        const SizedBox(height: 15),

                        Text("Login", style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 20),

                        if (_errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error, color: Colors.red),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => setState(() => _errorMessage = null),
                                  child: const Icon(Icons.close, color: Colors.red),
                                ),
                              ],
                            ),
                          ),

                        // Email Input
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) =>
                              value!.isEmpty ? "Enter a valid email" : null,
                        ),
                        const SizedBox(height: 10),

                        // Password Input
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) =>
                              value!.length < 6 ? "Password must be at least 6 characters" : null,
                        ),
                        const SizedBox(height: 10),

                        // Remember Me Checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) => setState(() => _rememberMe = value!),
                            ),
                            const Text("Remember me"),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Login Button
                        _isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () => _login(context),
                                child: const Text("Login"),
                              ),
                        const SizedBox(height: 10),

                        // Sign Up Link
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/signup'),
                          child: const Text("Don't have an account? Sign up"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
