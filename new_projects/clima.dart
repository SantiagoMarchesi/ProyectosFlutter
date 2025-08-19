import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;String _geoBase = 'https://geocoding-api.open-meteo.com/v1/search';

void main() => runApp(const ClimaApp());

class ClimaApp extends StatelessWidget {
  const ClimaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clima',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const ClimaPage(),
    );
  }
}

/* ─────────────────────────── Datos & Servicio ─────────────────────────── */

class City {
  final String name;
  final String country;
  final double lat;
  final double lon;
  final String? admin1; // provincia/estado
  City({
    required this.name,
    required this.country,
    required this.lat,
    required this.lon,
    this.admin1,
  });
  String get display =>
      admin1 == null || admin1!.isEmpty ? '$name, $country' : '$name, $admin1, $country';

  static List<City> fromGeocodingJson(Map<String, dynamic> json) {
    final results = (json['results'] as List?) ?? const [];
    return results.map((e) {
      return City(
        name: e['name'] ?? '',
        country: e['country'] ?? '',
        lat: (e['latitude'] as num).toDouble(),
        lon: (e['longitude'] as num).toDouble(),
        admin1: e['admin1'],
      );
    }).toList();
  }
}

class CurrentWeather {
  final double temp;
  final double feelsLike;
  final int humidity;
  final double wind;
  final int code;
  CurrentWeather({
    required this.temp,
    required this.feelsLike,
    required this.humidity,
    required this.wind,
    required this.code,
  });
}

class DailyForecast {
  final DateTime date;
  final double tMin;
  final double tMax;
  final int code;
  DailyForecast({
    required this.date,
    required this.tMin,
    required this.tMax,
    required this.code,
  });
}

class WeatherBundle {
  final String timezone;
  final CurrentWeather current;
  final List<DailyForecast> daily;
  WeatherBundle({required this.timezone, required this.current, required this.daily});
}

class WeatherService {
  static const _geoBase = 'https://geocoding-api.open-meteo.com/v1/search';
  static const _wxBase = 'https://api.open-meteo.com/v1/forecast';

  Future<List<City>> searchCity(String query) async {
    final uri = Uri.parse('$_geoBase?name=$query&count=8&language=es&format=json');
    final res = await http.get(uri);
    if (res.statusCode != 200) throw Exception('Error geocoding: ${res.statusCode}');
    return City.fromGeocodingJson(json.decode(res.body) as Map<String, dynamic>);
  }

  Future<WeatherBundle> fetchWeather(double lat, double lon) async {
    final params = {
      'latitude': '$lat',
      'longitude': '$lon',
      'current': 'temperature_2m,apparent_temperature,relative_humidity_2m,weather_code,wind_speed_10m',
      'daily': 'weather_code,temperature_2m_max,temperature_2m_min',
      'timezone': 'auto',
    };
    final uri = Uri.parse(_wxBase).replace(queryParameters: params);
    final res = await http.get(uri);
    if (res.statusCode != 200) throw Exception('Error forecast: ${res.statusCode}');
    final data = json.decode(res.body) as Map<String, dynamic>;

    final cur = data['current'] as Map<String, dynamic>;
    final d = data['daily'] as Map<String, dynamic>;
    final times = (d['time'] as List).cast<String>();
    final tmin = (d['temperature_2m_min'] as List).cast<num>();
    final tmax = (d['temperature_2m_max'] as List).cast<num>();
    final codes = (d['weather_code'] as List).cast<num>();

    final daily = <DailyForecast>[];
    for (int i = 0; i < times.length; i++) {
      daily.add(DailyForecast(
        date: DateTime.tryParse(times[i]) ?? DateTime.now(),
        tMin: tmin[i].toDouble(),
        tMax: tmax[i].toDouble(),
        code: codes[i].toInt(),
      ));
    }

    final current = CurrentWeather(
      temp: (cur['temperature_2m'] as num).toDouble(),
      feelsLike: (cur['apparent_temperature'] as num).toDouble(),
      humidity: (cur['relative_humidity_2m'] as num).toInt(),
      wind: (cur['wind_speed_10m'] as num).toDouble(),
      code: (cur['weather_code'] as num).toInt(),
    );

    return WeatherBundle(
      timezone: (data['timezone'] ?? 'UTC') as String,
      current: current,
      daily: daily,
    );
  }
}

/* ──────────────────────────────── UI ──────────────────────────────── */

class ClimaPage extends StatefulWidget {
  const ClimaPage({super.key});
  @override
  State<ClimaPage> createState() => _ClimaPageState();
}

class _ClimaPageState extends State<ClimaPage> {
  final _svc = WeatherService();
  final _q = TextEditingController(text: 'Córdoba'); // valor inicial útil
  List<City> _matches = [];
  City? _selected;
  WeatherBundle? _data;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  Future<void> _doSearch() async {
    final query = _q.text.trim();
    if (query.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
      _matches = [];
      _data = null;
    });
    try {
      final results = await _svc.searchCity(query);
      if (results.isEmpty) {
        setState(() {
          _loading = false;
          _error = 'No se encontraron ciudades para “$query”.';
        });
        return;
      }
      setState(() {
        _matches = results;
        _loading = false;
      });
      // Si quieres cargar automáticamente el primer resultado, descomenta:
      // _selectCity(results.first);
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _selectCity(City c) async {
    setState(() {
      _selected = c;
      _loading = true;
      _error = null;
      _data = null;
    });
    try {
      final data = await _svc.fetchWeather(c.lat, c.lon);
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Clima (Open-Meteo)')),
      body: SafeArea(
        child: Column(
          children: [
            // Buscador
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _q,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _doSearch(),
                      decoration: const InputDecoration(
                        labelText: 'Buscar ciudad',
                        hintText: 'Ej: Córdoba, Buenos Aires, Madrid',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: _doSearch, child: const Text('Buscar')),
                ],
              ),
            ),

            // Estado / resultados
            if (_loading) const LinearProgressIndicator(),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _ErrorBanner(text: _error!),
              ),

            // Datos del clima
            Expanded(
              child: _data == null
                  ? Center(
                child: Text(
                  _selected == null
                      ? 'Busca una ciudad para ver el clima.'
                      : 'Cargando clima para ${_selected!.display}…',
                  style: TextStyle(color: scheme.outline),
                ),
              )
                  : _WeatherView(city: _selected!, data: _data!),
            ),
          ],
        ),
      ),
    );
  }
}

/* ──────────────────────────── Widgets UI ──────────────────────────── */

class _CityResults extends StatelessWidget {
  final List<City> items;
  final ValueChanged<City> onPick;
  const _CityResults({required this.items, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: scheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.all(8),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final c = items[i];
          return ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: Text(c.display),
            subtitle: Text('Lat: ${c.lat.toStringAsFixed(2)}  Lon: ${c.lon.toStringAsFixed(2)}'),
            onTap: () => onPick(c),
          );
        },
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String text;
  const _ErrorBanner({required this.text});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: scheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: scheme.onErrorContainer)),
          ),
        ],
      ),
    );
  }
}

class _WeatherView extends StatelessWidget {
  final City city;
  final WeatherBundle data;
  const _WeatherView({required this.city, required this.data});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = data.current;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header ciudad
          Row(
            children: [
              Icon(_iconForCode(c.code), size: 32, color: scheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  city.display,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(data.timezone, style: TextStyle(color: scheme.outline)),
            ],
          ),
          const SizedBox(height: 12),

          // Tarjetas métricas actuales
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetricCard(
                label: 'Temp',
                value: '${c.temp.toStringAsFixed(1)}°C',
                icon: Icons.thermostat,
              ),
              _MetricCard(
                label: 'Térmica',
                value: '${c.feelsLike.toStringAsFixed(1)}°C',
                icon: Icons.device_thermostat,
              ),
              _MetricCard(
                label: 'Humedad',
                value: '${c.humidity}%',
                icon: Icons.water_drop_outlined,
              ),
              _MetricCard(
                label: 'Viento',
                value: '${c.wind.toStringAsFixed(0)} km/h',
                icon: Icons.air,
              ),
              _MetricCard(
                label: 'Cielo',
                value: _descForCode(c.code),
                icon: _iconForCode(c.code),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text('Próximos días', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),

          // Lista diaria
          Expanded(
            child: ListView.separated(
              itemCount: data.daily.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final d = data.daily[i];
                return ListTile(
                  leading: Icon(_iconForCode(d.code)),
                  title: Text(_formatDate(d.date)),
                  subtitle: Text(_descForCode(d.code)),
                  trailing: Text('${d.tMin.toStringAsFixed(0)}° / ${d.tMax.toStringAsFixed(0)}°'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _MetricCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value),
        ],
      ),
    );
  }
}

/* ───────────────────────── Utilidades (WMO) ───────────────────────── */

String _formatDate(DateTime d) {
  // formato corto yyyy-mm-dd -> dd/mm
  final two = (int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)}';
}

// Descripciones rápidas por código WMO
String _descForCode(int code) {
  if (code == 0) return 'Despejado';
  if ([1, 2, 3].contains(code)) return 'Parcial/Mayormente nublado';
  if ([45, 48].contains(code)) return 'Niebla';
  if ([51, 53, 55].contains(code)) return 'Llovizna';
  if ([56, 57].contains(code)) return 'Llovizna helada';
  if ([61, 63, 65].contains(code)) return 'Lluvia';
  if ([66, 67].contains(code)) return 'Lluvia helada';
  if ([71, 73, 75].contains(code)) return 'Nieve';
  if (code == 77) return 'Cristales de hielo';
  if ([80, 81, 82].contains(code)) return 'Chubascos';
  if ([85, 86].contains(code)) return 'Chubascos de nieve';
  if (code == 95) return 'Tormenta';
  if ([96, 99].contains(code)) return 'Tormenta con granizo';
  return 'Condición $code';
}

IconData _iconForCode(int code) {
  if (code == 0) return Icons.wb_sunny_outlined;
  if ([1, 2, 3].contains(code)) return Icons.cloud_outlined;
  if ([45, 48].contains(code)) return Icons.foggy; // puede no estar en algunas versiones
  if ([51, 53, 55, 61, 63, 65, 80, 81, 82].contains(code)) return Icons.umbrella_outlined;
  if ([71, 73, 75, 85, 86].contains(code)) return Icons.ac_unit_outlined;
  if ([56, 57, 66, 67].contains(code)) return Icons.icecream_outlined;
  if ([95, 96, 99].contains(code)) return Icons.bolt_outlined;
  return Icons.help_outline;
}
