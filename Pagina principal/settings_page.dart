import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _menuItem = 'Opción 1';
  bool _notifications = true;
  bool _darkMode = false;
  double _volume = 0.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dropdown de ejemplo
              DropdownButtonFormField<String>(
                value: _menuItem,
                decoration: const InputDecoration(labelText: 'Opción'),
                items: const [
                  DropdownMenuItem(value: 'Opción 1', child: Text('Opción 1')),
                  DropdownMenuItem(value: 'Opción 2', child: Text('Opción 2')),
                  DropdownMenuItem(value: 'Opción 3', child: Text('Opción 3')),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _menuItem = v);
                },
              ),

              const SizedBox(height: 12),

              // Switches
              SwitchListTile.adaptive(
                title: const Text('Notificaciones'),
                value: _notifications,
                onChanged: (v) => setState(() => _notifications = v),
              ),
              SwitchListTile.adaptive(
                title: const Text('Modo oscuro'),
                value: _darkMode,
                onChanged: (v) => setState(() => _darkMode = v),
              ),

              const SizedBox(height: 12),

              // Slider (barra de tamaño/volumen)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Volumen'),
                subtitle: Slider(
                  value: _volume,
                  onChanged: (v) => setState(() => _volume = v),
                ),
                trailing: Text('${(_volume * 100).round()}%'),
              ),

              const SizedBox(height: 16),

              // Botón de Guardar
              ElevatedButton.icon(
                onPressed: () {
                  // Aquí guardas preferencias si hace falta
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Preferencias guardadas')),
                  );
                },
                icon: const Icon(Icons.save),
                label: const Text('Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
