import 'package:flutter/material.dart';

void main() => runApp(const QuizApp());

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quiz',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const QuizPage(),
    );
  }
}

class Question {
  final String text;
  final List<String> options;
  final int correctIndex;

  const Question({required this.text, required this.options, required this.correctIndex});
}

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});
  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final List<Question> _questions = const [
    Question(
      text: '¿Qué widget se usa para crear una lista que se desplaza verticalmente?',
      options: ['Column', 'ListView', 'Stack', 'GridView'],
      correctIndex: 1,
    ),
    Question(
      text: '¿Qué clase usas para manejar estado simple en Flutter?',
      options: ['StatelessWidget', 'StatefulWidget', 'InheritedWidget', 'Navigator'],
      correctIndex: 1,
    ),
    Question(
      text: '¿Cómo navegas a otra pantalla?',
      options: [
        'Theme.of(context)',
        'MediaQuery.of(context)',
        'Navigator.push(...)',
        'setState(() { ... })'
      ],
      correctIndex: 2,
    ),
    Question(
      text: '¿Qué método se llama para reconstruir la UI con nuevos datos?',
      options: ['build', 'createState', 'setState', 'runApp'],
      correctIndex: 2,
    ),
    Question(
      text: '¿Cuál es el archivo principal por convención en un proyecto Flutter?',
      options: ['pubspec.yaml', 'main.dart', 'widget_tree.dart', 'manifest.json'],
      correctIndex: 1,
    ),
  ];

  int _current = 0;
  int _score = 0;
  int? _selected; // índice de opción elegida en la pregunta actual
  bool _finished = false;

  void _next() {
    if (_selected == null) return;
    // sumamos si acertó
    if (_selected == _questions[_current].correctIndex) {
      _score++;
    }

    if (_current < _questions.length - 1) {
      setState(() {
        _current++;
        _selected = null; // limpiar selección para la próxima pregunta
      });
    } else {
      setState(() {
        _finished = true;
      });
    }
  }

  void _restart() {
    setState(() {
      _current = 0;
      _score = 0;
      _selected = null;
      _finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = _questions.length;
    final progress = _finished ? 1.0 : (_current) / total;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Flutter'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _finished ? _buildResult(context) : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progreso
              Text('Pregunta ${_current + 1} de $total',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(value: progress),
              ),
              const SizedBox(height: 20),

              // Enunciado
              Text(
                _questions[_current].text,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),

              // Opciones (se adaptan sin overflow)
              Expanded(
                child: ListView.separated(
                  itemCount: _questions[_current].options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final option = _questions[_current].options[i];
                    final selected = _selected == i;

                    return ChoiceChipCard(
                      label: option,
                      selected: selected,
                      onTap: () => setState(() => _selected = i),
                    );
                  },
                ),
              ),

              // Botón Siguiente
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _selected == null ? null : _next,
                child: Text(_current == total - 1 ? 'Finalizar' : 'Siguiente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResult(BuildContext context) {
    final total = _questions.length;
    final pct = ((_score / total) * 100).toStringAsFixed(0);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _score >= (total * 0.6) ? Icons.emoji_events : Icons.insights,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text('¡Resultado!', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Aciertos: $_score / $total  •  $pct%',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.tonal(
              onPressed: _restart,
              child: const Text('Reiniciar Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta tipo botón para opciones (bonita y accesible)
class ChoiceChipCard extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const ChoiceChipCard({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = selected ? scheme.primaryContainer : scheme.surfaceContainerHighest;
    final fg = selected ? scheme.onPrimaryContainer : scheme.onSurface;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: selected ? scheme.primary : scheme.outline,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: fg),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
