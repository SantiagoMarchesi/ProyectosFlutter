import 'package:flutter/material.dart';
import 'login.dart';
// Si usas Provider para tema/ajustes, mantén tus imports:
// import 'package:provider/provider.dart';
// import 'notifiers.dart';
// import 'settings_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        // actions: [ ... tu botón de tema y ajustes si ya estaban ... ],
      ),
      drawer: const Drawer(), // o tu AppDrawer si tienes uno
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Gráfico de portada (sin assets)
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0f2027), Color(0xFF2c5364)],
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Flutter Mapp',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(letterSpacing: 6, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: 140,
                  height: 44,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    child: const Text('Login'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
