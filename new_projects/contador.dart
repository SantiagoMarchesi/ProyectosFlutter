import 'package:flutter/material.dart';

void main() => runApp(const CounterApp());

class CounterApp extends StatelessWidget {
  const CounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Contador',
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size(120, 48),
          ),
        ),
      ),
      home: const CounterPage(),
    );
  }
}

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});
  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _count = 0;

  void _add(int n) => setState(() => _count += n);
  void _reset() => setState(() => _count = 0);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Contador')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Pantalla del contador
              Expanded(
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$_count',
                      style: TextStyle(
                        fontSize: 96,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),

              // Botones (se adaptan y no hacen overflow)
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  // Restar
                  FilledButton.tonal(
                    onPressed: () => _add(-1),
                    child: const Text('-1'),
                  ),
                  FilledButton.tonal(
                    onPressed: () => _add(-10),
                    child: const Text('-10'),
                  ),
                  FilledButton.tonal(
                    onPressed: () => _add(-100),
                    child: const Text('-100'),
                  ),
                  // Sumar
                  FilledButton.tonal(
                    onPressed: () => _add(1),
                    child: const Text('+1'),
                  ),
                  FilledButton(
                    onPressed: () => _add(10),
                    child: const Text('+10'),
                  ),
                  FilledButton(
                    onPressed: () => _add(100),
                    child: const Text('+100'),
                  ),
                  // Reiniciar
                  OutlinedButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reiniciar'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      minimumSize: const Size(120, 48),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      side: BorderSide(color: scheme.outline),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
