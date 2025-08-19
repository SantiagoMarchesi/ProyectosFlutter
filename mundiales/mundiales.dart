import 'package:flutter/material.dart';
import 'lista_datos.dart' show mundiales;

void main() => runApp(const MundialesApp());

class MundialesApp extends StatelessWidget {
  const MundialesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mundiales FIFA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
      home: const MundialesPage(),
    );
  }
}

// -------------------- MODELO --------------------
class Scorer {
  final String nombre;
  final String pais;
  final int goles;
  const Scorer({required this.nombre, required this.pais, required this.goles});
}

class Mundial {
  final int anio;
  final List<String> sedes;
  final String campeon;
  final String subcampeon;
  final String marcadorFinal;
  final String? nota;
  final List<Scorer> goleadores; // NUEVO

  const Mundial({
    required this.anio,
    required this.sedes,
    required this.campeon,
    required this.subcampeon,
    required this.marcadorFinal,
    this.nota,
    this.goleadores = const [],
  });
}

// Dataset compacto (1930–2022) + goleadores principales


// -------------------- PÁGINA LISTA --------------------
class MundialesPage extends StatefulWidget {
  const MundialesPage({super.key});

  @override
  State<MundialesPage> createState() => _MundialesPageState();
}

class _MundialesPageState extends State<MundialesPage> {
  final List<Mundial> _mundiales = mundiales;
  String _query = '';
  String _filtroCampeon = 'Todos';
  bool _asc = true;

  late final Set<String> _campeonesDisponibles = {
    'Todos',
    ...mundiales.map((m) => m.campeon),
  };

  List<Mundial> get _filtrados {
    final q = _query.trim().toLowerCase();
    final list = mundiales.where((m) {
      final matchFiltro = _filtroCampeon == 'Todos' || m.campeon == _filtroCampeon;
      if (!matchFiltro) return false;
      if (q.isEmpty) return true;

      final enTexto = <String>[
        '${m.anio}',
        ...m.sedes,
        m.campeon,
        m.subcampeon,
        m.marcadorFinal,
        m.nota ?? '',
      ].join(' ').toLowerCase();

      return enTexto.contains(q);
    }).toList();

    list.sort((a, b) => _asc ? a.anio.compareTo(b.anio) : b.anio.compareTo(a.anio));
    return list;
  }

  int get _totalEdiciones => _mundiales.length;

  Map<String, int> get _titulosPorPais {
    final Map<String, int> map = {};
    for (final m in _mundiales) {
      final key = _normalizarPais(m.campeon);
      map[key] = (map[key] ?? 0) + 1;
    }
    return map;
  }

  String get _topPais {
    final map = _titulosPorPais;
    if (map.isEmpty) return '-';
    final sorted = map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.first;
    return '${top.key} (${top.value})';
  }

  String _normalizarPais(String p) {
    switch (p) {
      case 'Alemania Occidental':
        return 'Alemania';
      default:
        return p;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mundiales FIFA (1930–2022)'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ----- Controles superiores -----
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Buscar por año, sede, campeón, subcampeón…',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (v) => setState(() => _query = v),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton.filledTonal(
                        onPressed: () => setState(() => _asc = !_asc),
                        tooltip: _asc ? 'Ordenar por año (desc)' : 'Ordenar por año (asc)',
                        icon: Icon(_asc ? Icons.arrow_upward : Icons.arrow_downward),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Filtrar por campeón:'),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _filtroCampeon,
                          items: _campeonesDisponibles
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (v) => setState(() => _filtroCampeon = v ?? 'Todos'),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ----- Métricas rápidas -----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  _StatChip(
                    label: 'Ediciones',
                    value: '$_totalEdiciones',
                    color: scheme.primaryContainer,
                    onColor: scheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    label: 'Más títulos',
                    value: _topPais,
                    color: scheme.secondaryContainer,
                    onColor: scheme.onSecondaryContainer,
                  ),
                ],
              ),
            ),

            // ----- Lista (tap para abrir detalle) -----
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: _filtrados.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final m = _filtrados[i];
                  return _MundialCard(
                    m: m,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MundialDetailPage(m: m),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------- DETALLE --------------------
class MundialDetailPage extends StatelessWidget {
  final Mundial m;
  const MundialDetailPage({super.key, required this.m});

  void _openStats(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _StatsSheet(m: m),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mundial ${m.anio}'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Año grande (Hero)
                  Hero(
                    tag: 'year-${m.anio}',
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: scheme.primary.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '${m.anio}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _InfoRow(icon: Icons.public, label: 'Sede(s)', value: m.sedes.join(' • ')),
                  const SizedBox(height: 10),
                  _InfoRow(icon: Icons.emoji_events, label: 'Campeón', value: m.campeon, bold: true),
                  const SizedBox(height: 8),
                  _InfoRow(icon: Icons.military_tech, label: 'Subcampeón', value: m.subcampeon),
                  const SizedBox(height: 8),
                  _InfoRow(icon: Icons.sports_soccer, label: 'Final', value: m.marcadorFinal),
                  if (m.nota != null) ...[
                    const SizedBox(height: 8),
                    _InfoRow(icon: Icons.info_outline, label: 'Nota', value: m.nota!),
                  ],

                  const SizedBox(height: 24),
                  // Botones de acción
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed: () => _openStats(context),
                        icon: const Icon(Icons.bar_chart),
                        label: const Text('Ver estadísticas'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Volver'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------- STATS SHEET (VENTANA) --------------------
class _StatsSheet extends StatelessWidget {
  final Mundial m;
  const _StatsSheet({required this.m});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Ordena goleadores por goles desc y nombre asc
    final top = [...m.goleadores]
      ..sort((a, b) {
        final byGoals = b.goles.compareTo(a.goles);
        return byGoals != 0 ? byGoals : a.nombre.compareTo(b.nombre);
      });

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75, // 75% alto de pantalla
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Material(
          color: Theme.of(context).colorScheme.surface,
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Text(
                'Estadísticas ${m.anio}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text('Campeón: ${m.campeon}  •  Subcampeón: ${m.subcampeon}'),

              const SizedBox(height: 16),
              _SectionTitle(icon: Icons.sports_soccer, title: 'Goleadores'),
              const SizedBox(height: 8),

              if (top.isEmpty)
                _EmptyCard(
                  text:
                  'No hay goleadores cargados para ${m.anio}. Puedes agregarlos en el dataset.',
                )
              else
                Card(
                  elevation: 0,
                  color: scheme.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: DataTable(
                      headingRowHeight: 40,
                      dataRowMinHeight: 44,
                      dataRowMaxHeight: 56,
                      columns: const [
                        DataColumn(label: Text('Jugador')),
                        DataColumn(label: Text('País')),
                        DataColumn(label: Text('Goles')),
                      ],
                      rows: top
                          .map(
                            (s) => DataRow(
                          cells: [
                            DataCell(Text(s.nombre)),
                            DataCell(Text(s.pais)),
                            DataCell(Text('${s.goles}')),
                          ],
                        ),
                      )
                          .toList(),
                    ),
                  ),
                ),

              const SizedBox(height: 16),
              // Otras ideas de stats (de muestra)
              _SectionTitle(icon: Icons.query_stats, title: 'Otras métricas (demo)'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatPill(label: 'Sedes', value: m.sedes.length.toString()),
                  _StatPill(label: 'Final', value: m.marcadorFinal),
                ],
              ),

              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonalIcon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: TextStyle(color: scheme.onSecondaryContainer, fontWeight: FontWeight.w600)),
          Text(value, style: TextStyle(color: scheme.onSecondaryContainer)),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String text;
  const _EmptyCard({required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: scheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: scheme.primary),
            const SizedBox(width: 10),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}

// -------------------- UI AUXILIAR --------------------
class _MundialCard extends StatelessWidget {
  final Mundial m;
  final VoidCallback onTap;
  const _MundialCard({required this.m, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(14);

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: radius),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Año grande (Hero para animación suave al detalle)
              Hero(
                tag: 'year-${m.anio}',
                child: Container(
                  width: 68,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: scheme.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${m.anio}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: scheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Datos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.public, size: 18),
                      const SizedBox(width: 6),
                      Flexible(child: Text('Sede: ${m.sedes.join(' • ')}')),
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.emoji_events, size: 18),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Campeón: ${m.campeon}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.military_tech, size: 18),
                      const SizedBox(width: 6),
                      Flexible(child: Text('Subcampeón: ${m.subcampeon}')),
                    ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.sports_soccer, size: 18),
                      const SizedBox(width: 6),
                      Flexible(child: Text('Final: ${m.marcadorFinal}')),
                    ]),
                    if (m.nota != null) ...[
                      const SizedBox(height: 6),
                      Row(children: [
                        const Icon(Icons.info_outline, size: 18),
                        const SizedBox(width: 6),
                        Flexible(child: Text(m.nota!)),
                      ]),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color onColor;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.onColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.w600, color: onColor)),
          Text(value, style: TextStyle(color: onColor)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool bold;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: t.bodyLarge,
              children: [
                TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
                TextSpan(text: value, style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
