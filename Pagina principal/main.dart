import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'notifiers.dart';
import 'widget_tree.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => SelectedPageNotifier()),
        ChangeNotifierProvider(create: (_) => SettingsNotifier()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Lee el modo de tema desde ThemeNotifier
    final themeMode = context.watch<ThemeNotifier>().mode;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Activa Material 3 y define esquemas para claro/oscuro
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
      ),

      // Arranca en tu árbol principal (WelcomePage en el índice 0)
      home: const WidgetTree(),

      // Si en algún momento quieres rutas con nombre, puedes agregarlas aquí.
      // routes: {
      //   '/welcome': (_) => const WelcomePage(),
      //   '/login': (_) => const LoginPage(),
      //   '/profile': (_) => const ProfilePage(),
      //   '/settings': (_) => const SettingsPage(),
      // },
    );
  }
}
