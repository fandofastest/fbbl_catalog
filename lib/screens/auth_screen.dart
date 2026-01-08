import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth';
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _registerMode = true;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    if (!_formKey.currentState!.validate()) return;
    final scaffold = ScaffoldMessenger.of(context);
    final success = _registerMode
        ? await auth.register(
            name: _nameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            address: _addressCtrl.text.trim(),
          )
        : await auth.login(
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text.trim(),
          );
    if (!mounted) return;
    if (success) {
      scaffold.showSnackBar(
        SnackBar(content: Text(_registerMode ? 'Registration successful' : 'Signed in successfully')),
      );
      Navigator.of(context).pop();
    } else if (auth.error != null) {
      scaffold.showSnackBar(SnackBar(content: Text(auth.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_registerMode ? 'Create account' : 'Sign in'),
        actions: [
          TextButton(
            onPressed: auth.loading
                ? null
                : () {
                    setState(() {
                      _registerMode = !_registerMode;
                    });
                    auth.clearError();
                  },
            child: Text(
              _registerMode ? 'Already have an account?' : 'Need an account?',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _registerMode ? 'Create a new business account' : 'Sign in with email',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      if (_registerMode)
                        TextFormField(
                          controller: _nameCtrl,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(labelText: 'Full name'),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                        ),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Email is required';
                          if (!v.contains('@')) return 'Please enter a valid email address';
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: 'Password'),
                        validator: (v) => v != null && v.length >= 6 ? null : 'Password must be at least 6 characters',
                      ),
                      if (_registerMode) ...[
                        TextFormField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(labelText: 'WhatsApp number'),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Phone number is required' : null,
                        ),
                        TextFormField(
                          controller: _addressCtrl,
                          minLines: 2,
                          maxLines: 3,
                          decoration: const InputDecoration(labelText: 'Business address'),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Address is required' : null,
                        ),
                      ],
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: auth.loading ? null : _submit,
                        child: auth.loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(_registerMode ? 'Register & sign in' : 'Sign in'),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'By ${_registerMode ? 'registering' : 'signing in'}, you agree to let the FBBL sales team process orders manually.',
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
