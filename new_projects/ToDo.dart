import 'package:flutter/material.dart';

void main() => runApp(const TodoApp());

// App mínima: solo muestra la página de To-Do
class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do básica',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo, // paleta base (Material 3)
        useMaterial3: true,
      ),
      home: const TodoPage(),
    );
  }
}

/*─────────────────────────────
  MODELO DE DATO (TAREA)
─────────────────────────────*/
class Todo {
  String text;            // descripción de la tarea
  bool done;              // estado: hecha o no
  final DateTime createdAt; // timestamp para clave única/orden

  Todo({required this.text, this.done = false}) : createdAt = DateTime.now();
}

/*─────────────────────────────
  PANTALLA PRINCIPAL
─────────────────────────────*/
class TodoPage extends StatefulWidget {
  const TodoPage({super.key});
  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  // Controlador del TextField para leer el texto escrito por el usuario
  final _ctrl = TextEditingController();

  // Lista en memoria de tareas (no persiste al cerrar la app)
  final List<Todo> _items = [];

  @override
  void dispose() {
    _ctrl.dispose(); // siempre liberar controladores
    super.dispose();
  }

  // Agrega una tarea nueva al inicio de la lista
  void _addTodo() {
    final text = _ctrl.text.trim(); // quitamos espacios
    if (text.isEmpty) return;       // ignorar entradas vacías
    setState(() => _items.insert(0, Todo(text: text))); // mutación reactiva
    _ctrl.clear(); // limpiamos el campo
  }

  // Marca/Desmarca una tarea como hecha
  void _toggle(Todo t, bool? v) {
    setState(() => t.done = v ?? false);
  }

  // Elimina una tarea por índice y muestra SnackBar con opción de deshacer
  void _deleteAt(int index) {
    final removed = _items.removeAt(index); // quitamos de la lista
    setState(() {}); // forzamos reconstrucción

    // Aviso visual con acción de deshacer (vuelve a insertar la tarea)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Eliminado: "${removed.text}"'),
        action: SnackBarAction(
          label: 'DESHACER',
          onPressed: () {
            setState(() => _items.insert(index, removed));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bottom = MediaQuery.of(context).viewInsets.bottom; // alto del teclado

    return Scaffold(
      appBar: AppBar(title: const Text('To-Do básica')),
      body: SafeArea(
        child: Column(
          children: [
            // ── Sección de entrada: TextField + botón "Agregar" ──
            Padding(
              // añadimos espacio extra abajo cuando el teclado está abierto
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8 + bottom),
              child: Row(
                children: [
                  // TextField expandido para escribir la tarea
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      onSubmitted: (_) => _addTodo(), // enter agrega
                      decoration: const InputDecoration(
                        labelText: 'Nueva tarea',
                        hintText: 'Ej: Comprar pan',
                        prefixIcon: Icon(Icons.add_task_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Botón para confirmar el agregado
                  FilledButton(
                    onPressed: _addTodo,
                    child: const Text('Agregar'),
                  ),
                ],
              ),
            ),

            // ── Lista de tareas (o estado vacío) ──
            Expanded(
              child: _items.isEmpty
              // Mensaje cuando no hay tareas
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inbox_outlined, size: 48, color: scheme.outline),
                    const SizedBox(height: 8),
                    Text('Sin tareas. ¡Agrega la primera!',
                        style: TextStyle(color: scheme.outline)),
                  ],
                ),
              )
              // Lista con separación entre ítems
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final t = _items[index];

                  // Dismissible permite arrastrar para borrar (swipe)
                  return Dismissible(
                    // clave única por ítem (mezclamos tiempo + texto)
                    key: ValueKey('${t.createdAt.millisecondsSinceEpoch}-${t.text}'),

                    // Fondo al hacer swipe de izquierda a derecha
                    background: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      color: Colors.red.withOpacity(0.10),
                      child: const Icon(Icons.delete_outline),
                    ),
                    // Fondo al hacer swipe de derecha a izquierda
                    secondaryBackground: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      color: Colors.red.withOpacity(0.10),
                      child: const Icon(Icons.delete_outline),
                    ),

                    // Cuando se completa el gesto de borrar
                    onDismissed: (_) => _deleteAt(index),

                    // Contenido del ítem: checkbox + título + botón eliminar
                    child: CheckboxListTile(
                      value: t.done,                    // estado actual
                      onChanged: (v) => _toggle(t, v),  // cambio de estado
                      title: Text(
                        t.text,
                        // Si está hecha, tachamos y bajamos contraste
                        style: TextStyle(
                          decoration: t.done ? TextDecoration.lineThrough : null,
                          color: t.done ? scheme.outline : null,
                        ),
                      ),
                      controlAffinity: ListTileControlAffinity.leading, // checkbox a la izquierda
                      secondary: IconButton(
                        tooltip: 'Eliminar',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteAt(index), // borrar con botón
                      ),
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


