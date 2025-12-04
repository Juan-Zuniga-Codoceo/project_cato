import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../../../home/presentation/screens/home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticating = false;
  String _authorized = 'Not Authorized';

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
        localizedReason: 'Escanea tu huella o rostro para acceder',
      );
      setState(() {
        _isAuthenticating = false;
      });
    } catch (e) {
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error - ${e.toString()}';
      });
      return;
    }

    if (!mounted) return;

    setState(() {
      _authorized = authenticated ? 'Authorized' : 'Not Authorized';
    });

    if (authenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 80, color: Colors.indigo),
            const SizedBox(height: 20),
            const Text(
              'Seguridad Biométrica',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              _isAuthenticating ? 'Escaneando...' : 'Toca para reintentar',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            if (!_isAuthenticating)
              ElevatedButton(
                onPressed: _authenticate,
                child: const Text('Autenticar'),
              ),
          ],
        ),
      ),
    );
  }
}
