import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculadora',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 10), // compacto
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            elevation: 0,
            minimumSize: const Size(0, 0),
          ),
        ),
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});
  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _display = '0';
  double? _firstOperand;
  String? _operator;
  bool _shouldResetDisplay = false;
  bool _inError = false;

  // ---------- LÓGICA ----------
  void _clearAll() {
    setState(() {
      _display = '0';
      _firstOperand = null;
      _operator = null;
      _shouldResetDisplay = false;
      _inError = false;
    });
  }

  void _backspace() {
    if (_shouldResetDisplay || _inError) {
      setState(() => _display = '0');
      _inError = false;
      return;
    }
    setState(() {
      if (_display.length <= 1 || _display == '-0') {
        _display = '0';
      } else {
        _display = _display.substring(0, _display.length - 1);
        if (_display == '-' || _display.isEmpty) _display = '0';
      }
    });
  }

  void _inputDigit(String d) {
    if (_inError) _clearAll();
    setState(() {
      if (_shouldResetDisplay || _display == '0') {
        _display = d;
        _shouldResetDisplay = false;
      } else {
        _display += d;
      }
    });
  }

  void _inputDecimal() {
    if (_inError) _clearAll();
    setState(() {
      if (_shouldResetDisplay) {
        _display = '0.';
        _shouldResetDisplay = false;
      } else if (!_display.contains('.')) {
        _display += '.';
      }
    });
  }

  void _toggleSign() {
    if (_inError) _clearAll();
    setState(() {
      if (_display.startsWith('-')) {
        _display = _display.substring(1);
      } else if (_display != '0') {
        _display = '-$_display';
      }
    });
  }

  void _percent() {
    if (_inError) _clearAll();
    final v = double.tryParse(_display);
    if (v == null) return;
    setState(() => _display = _format(v / 100.0));
  }

  void _onOperator(String op) {
    if (_inError) _clearAll();
    final current = double.tryParse(_display) ?? 0;
    setState(() {
      if (_operator != null && !_shouldResetDisplay) {
        if (!_performCalculation(current)) return;
      } else {
        _firstOperand ??= current;
      }
      _operator = op;
      _shouldResetDisplay = true;
    });
  }

  void _onEquals() {
    if (_inError) _clearAll();
    if (_operator == null || _firstOperand == null) return;
    final current = double.tryParse(_display) ?? 0;
    setState(() {
      if (_performCalculation(current)) {
        _operator = null;
        _shouldResetDisplay = true;
      }
    });
  }

  bool _performCalculation(double second) {
    double a = _firstOperand ?? 0;
    double res;
    try {
      switch (_operator) {
        case '+':
          res = a + second;
          break;
        case '−':
        case '-':
          res = a - second;
          break;
        case '×':
          res = a * second;
          break;
        case '÷':
          if (second == 0) throw const FormatException('División por cero');
          res = a / second;
          break;
        default:
          return true;
      }
    } catch (_) {
      _display = 'Error';
      _firstOperand = null;
      _operator = null;
      _shouldResetDisplay = true;
      _inError = true;
      return false;
    }
    _display = _format(res);
    _firstOperand = res;
    _inError = false;
    return true;
  }

  String _format(double v) {
    if (v.isNaN || v.isInfinite) return 'Error';
    String s = v.toStringAsPrecision(12);
    if (s.contains('.')) {
      s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }
    return s;
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    final opsColor = Theme.of(context).colorScheme.primary;
    final actionColor = Theme.of(context).colorScheme.secondary;

    final buttons = <_KeySpec>[
      _KeySpec('AC', onTap: _clearAll, role: KeyRole.action),
      _KeySpec('⌫', onTap: _backspace, role: KeyRole.action),
      _KeySpec('%', onTap: _percent, role: KeyRole.action),
      _KeySpec('÷', onTap: () => _onOperator('÷'), role: KeyRole.op),
      _KeySpec('7', onTap: () => _inputDigit('7')),
      _KeySpec('8', onTap: () => _inputDigit('8')),
      _KeySpec('9', onTap: () => _inputDigit('9')),
      _KeySpec('×', onTap: () => _onOperator('×'), role: KeyRole.op),
      _KeySpec('4', onTap: () => _inputDigit('4')),
      _KeySpec('5', onTap: () => _inputDigit('5')),
      _KeySpec('6', onTap: () => _inputDigit('6')),
      _KeySpec('−', onTap: () => _onOperator('−'), role: KeyRole.op),
      _KeySpec('1', onTap: () => _inputDigit('1')),
      _KeySpec('2', onTap: () => _inputDigit('2')),
      _KeySpec('3', onTap: () => _inputDigit('3')),
      _KeySpec('+', onTap: () => _onOperator('+'), role: KeyRole.op),
      _KeySpec('±', onTap: _toggleSign, role: KeyRole.action),
      _KeySpec('0', onTap: () => _inputDigit('0')),
      _KeySpec('.', onTap: _inputDecimal),
      _KeySpec('=', onTap: _onEquals, role: KeyRole.equal),
    ];

    // Altura fija del teclado (zona inferior), pero adaptativa por pantalla
    final h = MediaQuery.of(context).size.height;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom; // teclado SO
    final keyboardHeight = (h - viewInsets) * 0.42; // ocupa ~42% de la pantalla

    return Scaffold(
      appBar: AppBar(title: const Text('Calculadora'), centerTitle: true),
      body: SafeArea(
        child: Column(
          children: [
            // Pantalla (parte superior)
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                alignment: Alignment.bottomRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    _display,
                    maxLines: 1,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 62,
                      fontWeight: FontWeight.w700,
                      color: _inError
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),

            // ---------- ZONA INFERIOR SIN SCROLL ----------
            SizedBox(
              height: keyboardHeight.clamp(240.0, 420.0), // límites razonables
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Calculamos ratio para que 4x5 celdas encajen sin overflow
                  const cols = 4;
                  const rows = 5;
                  const hSpacing = 8.0;
                  const vSpacing = 8.0;
                  const padH = 12.0 * 2; // padding horizontal total
                  const padV = 12.0;     // padding bottom

                  final gridWidth = constraints.maxWidth - padH - hSpacing * (cols - 1);
                  final gridHeight = constraints.maxHeight - padV - vSpacing * (rows - 1);

                  final cellWidth = gridWidth / cols;
                  final cellHeight = gridHeight / rows;
                  final aspectRatio = cellWidth / cellHeight;

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(), // sin scroll
                      itemCount: buttons.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        mainAxisSpacing: vSpacing,
                        crossAxisSpacing: hSpacing,
                        childAspectRatio: aspectRatio,
                      ),
                      itemBuilder: (context, i) {
                        final k = buttons[i];
                        final bg = switch (k.role) {
                          KeyRole.op => opsColor.withOpacity(0.12),
                          KeyRole.action => actionColor.withOpacity(0.10),
                          KeyRole.equal => Theme.of(context).colorScheme.primary,
                          _ => Theme.of(context).colorScheme.surfaceContainerHighest,
                        };
                        final fg = k.role == KeyRole.equal
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface;

                        // Texto que se adapta a la celda
                        final label = FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            k.label,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                          ),
                        );

                        return ElevatedButton(
                          onPressed: k.onTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: bg,
                            foregroundColor: fg,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                          ),
                          child: Center(child: label),
                        );
                      },
                    ),
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

// ---- Tipos auxiliares ----
enum KeyRole { num, op, action, equal }

class _KeySpec {
  final String label;
  final VoidCallback onTap;
  final KeyRole role;
  const _KeySpec(this.label, {required this.onTap, this.role = KeyRole.num});
}
