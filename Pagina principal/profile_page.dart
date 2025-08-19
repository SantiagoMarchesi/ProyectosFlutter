import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings_page.dart';
import 'notifiers.dart'; // Debe exponer ThemeNotifier con toggleTheme()

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          // Botón para cambiar el tema (no se quita)
          IconButton(
            tooltip: isDark ? 'Tema claro' : 'Tema oscuro',
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => context.read<ThemeNotifier>().toggleTheme(),
          ),
          // Llave de ajustes (lleva todo a SettingsPage)
          IconButton(
            tooltip: 'Ajustes',
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
        ],
      ),

      // Drawer se mantiene (no se quita).
      // Si ya tienes un Drawer propio (p. ej. AppDrawer en navbar_widgets.dart),
      // reemplaza todo este Drawer por: drawer: const AppDrawer(),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text('Menú', style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Perfil'),
              onTap: () => Navigator.pop(context), // ya estás en Perfil
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Ajustes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
            ),
          ],
        ),
      ),

      // Perfil “vacío” (como pediste). No quitamos nada más de la UI.
      body: const SizedBox.shrink(),
    );
  }
}






