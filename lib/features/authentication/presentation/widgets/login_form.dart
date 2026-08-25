import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../providers/auth_provider.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ref.read(authLoadingProvider.notifier).state = true;

    try {
      await ref
          .read(loginProvider)
          .call(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      if (!mounted) return;

      context.go(AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_firebaseErrorMessage(e.code))));
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        ref.read(authLoadingProvider.notifier).state = false;
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    ref.read(authLoadingProvider.notifier).state = true;

    try {
      await ref.read(loginWithGoogleProvider).call();

      if (!mounted) return;

      context.go(AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_firebaseErrorMessage(e.code))),
      );
    } catch (e) {
      debugPrint('[Google Sign-In] Error: $e');

      if (!mounted) return;

      // Show the real error so configuration issues are visible
      final msg = e.toString().contains('ApiException')
          ? 'Google Sign-In failed. Ensure SHA-1 is added to Firebase Console and google-services.json is up to date.'
          : e.toString().contains('network')
              ? 'Network error. Check your internet connection.'
              : 'Google Sign-In failed: ${e.toString().split('\n').first}';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          duration: const Duration(seconds: 6),
        ),
      );
    } finally {
      if (mounted) {
        ref.read(authLoadingProvider.notifier).state = false;
      }
    }
  }

  String _firebaseErrorMessage(String code) {
    switch (code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Invalid email or password.';

      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'user-disabled':
        return 'This account has been disabled.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      default:
        return 'Login failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authLoadingProvider);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'example@comsats.edu.pk',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              final email = value?.trim() ?? '';

              if (email.isEmpty) {
                return 'Please enter your email.';
              }

              if (!email.contains('@')) {
                return 'Please enter a valid email.';
              }

              return null;
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) {
              if (!isLoading) {
                _login();
              }
            },
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password.';
              }

              return null;
            },
          ),

          const SizedBox(height: 8),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: isLoading
                  ? null
                  : () {
                      context.push(AppRoutes.forgotPassword);
                    },
              child: const Text('Forgot Password?'),
            ),
          ),

          const SizedBox(height: 8),

          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading ? null : _login,
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Login'),
            ),
          ),

          const SizedBox(height: 16),

          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('OR', style: TextStyle(color: Colors.grey)),
              ),
              Expanded(child: Divider()),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            height: 52,
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isLoading ? null : _loginWithGoogle,
              icon: const Icon(Icons.g_mobiledata, size: 30),
              label: const Text('Sign in with Google'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Don't have an account? "),
              TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        context.push(AppRoutes.register);
                      },
                child: const Text('Create Account'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
