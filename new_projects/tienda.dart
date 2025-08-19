import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const ShopApp());

/*──────────────────────────────── APP & TEMA ───────────────────────────────*/

class ShopApp extends StatelessWidget {
  const ShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: AppState.demo(), // estado inicial con productos demo
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Tienda',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.indigo,
          brightness: Brightness.light,
          appBarTheme: const AppBarTheme(centerTitle: true),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.indigo,
          brightness: Brightness.dark,
          appBarTheme: const AppBarTheme(centerTitle: true),
        ),
        home: const HomePage(),
      ),
    );
  }
}

/*────────────────────────────── ESTADO (SIN PACKAGES) ──────────────────────*/

class Product {
  final String id;
  final String title;
  final String category;
  final String description;
  final double price;
  final double rating; // 0..5
  final List<Color> gradient; // representación visual
  final IconData icon;

  const Product({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.price,
    required this.rating,
    required this.gradient,
    required this.icon,
  });
}

class CartItem {
  final Product p;
  int qty;
  CartItem({required this.p, this.qty = 1});
}

enum SortBy { popular, priceLow, priceHigh }

class AppState extends ChangeNotifier {
  AppState();

  factory AppState.demo() {
    final rnd = Random(1);
    Color rndColor() => HSLColor.fromAHSL(
      1,
      rnd.nextDouble() * 360,
      0.60,
      0.55,
    ).toColor();

    List<Product> seed = [
      Product(
        id: 'p1',
        title: 'Auriculares Pro',
        category: 'Audio',
        description:
        'Cancelación de ruido activa, carga rápida y hasta 24 h de batería.',
        price: 129.99,
        rating: 4.6,
        gradient: [Colors.indigo, Colors.indigoAccent],
        icon: Icons.headphones_rounded,
      ),
      Product(
        id: 'p2',
        title: 'Smartwatch Fit',
        category: 'Wearables',
        description:
        'Registro de salud, GPS y resistencia al agua. Correas intercambiables.',
        price: 179.50,
        rating: 4.2,
        gradient: [Colors.teal, Colors.green],
        icon: Icons.watch_rounded,
      ),
      Product(
        id: 'p3',
        title: 'Cámara 4K',
        category: 'Cámaras',
        description:
        'Sensor 1/1.7", estabilización y video 4K60. Ideal para viajes.',
        price: 389.00,
        rating: 4.7,
        gradient: [Colors.purple, Colors.pink],
        icon: Icons.photo_camera_rounded,
      ),
      Product(
        id: 'p4',
        title: 'Teclado Mecánico',
        category: 'Accesorios',
        description:
        'Switches táctiles, RGB y cuerpo de aluminio. Layout 75%.',
        price: 99.90,
        rating: 4.4,
        gradient: [Colors.orange, Colors.deepOrange],
        icon: Icons.keyboard_rounded,
      ),
      Product(
        id: 'p5',
        title: 'Laptop 14"',
        category: 'Computo',
        description:
        'CPU de 8 núcleos, 16GB RAM y SSD NVMe. Batería para todo el día.',
        price: 1099.00,
        rating: 4.8,
        gradient: [Colors.blueGrey, Colors.lightBlue],
        icon: Icons.laptop_mac_rounded,
      ),
      Product(
        id: 'p6',
        title: 'Mouse Inalámbrico',
        category: 'Accesorios',
        description:
        'Bajo peso, sensor de alta precisión y batería de larga duración.',
        price: 39.90,
        rating: 4.1,
        gradient: [Colors.amber, Colors.yellow],
        icon: Icons.mouse_rounded,
      ),
      Product(
        id: 'p7',
        title: 'Parlante Portátil',
        category: 'Audio',
        description:
        'Sonido 360°, IP67 y 12 h de reproducción. Conexión multipunto.',
        price: 74.99,
        rating: 4.3,
        gradient: [Colors.cyan, Colors.blue],
        icon: Icons.speaker_rounded,
      ),
      Product(
        id: 'p8',
        title: 'Tablet 11"',
        category: 'Computo',
        description:
        'Pantalla 120 Hz, stylus y modo escritorio. Ideal para dibujar.',
        price: 459.00,
        rating: 4.5,
        gradient: [Colors.deepPurple, Colors.indigo],
        icon: Icons.tablet_android_rounded,
      ),
      Product(
        id: 'p9',
        title: 'Lentes VR',
        category: 'Wearables',
        description:
        'Pantallas OLED, seguimiento preciso y biblioteca de juegos.',
        price: 299.00,
        rating: 4.0,
        gradient: [Colors.red, Colors.pinkAccent],
        icon: Icons.vrpano_rounded,
      ),
      Product(
        id: 'p10',
        title: 'Micrófono USB',
        category: 'Audio',
        description:
        'Patrón cardioide, filtro pop y brazo incluido. Sonido nítido.',
        price: 89.00,
        rating: 4.4,
        gradient: [rndColor(), rndColor()],
        icon: Icons.mic_rounded,
      ),
    ];

    return AppState()
      .._all = seed
      .._filtered = seed;
  }

  // Datos
  List<Product> _all = [];
  List<Product> _filtered = [];
  final Set<String> _favorites = {};
  final Map<String, CartItem> _cart = {};

  // Filtros
  String _query = '';
  String _category = 'Todos';
  SortBy _sortBy = SortBy.popular;

  // Getters
  List<Product> get products => _filtered;
  Set<String> get favorites => _favorites;
  Map<String, CartItem> get cart => _cart;
  String get category => _category;
  SortBy get sortBy => _sortBy;
  String get query => _query;

  // Carrito
  int get cartCount => _cart.values.fold(0, (n, e) => n + e.qty);
  double get subtotal =>
      _cart.values.fold(0, (s, e) => s + e.qty * e.p.price);
  double get taxes => subtotal * 0.15;
  double get total => subtotal + taxes;

  void toggleFavorite(Product p) {
    if (_favorites.contains(p.id)) {
      _favorites.remove(p.id);
    } else {
      _favorites.add(p.id);
    }
    notifyListeners();
  }

  void addToCart(Product p, {int qty = 1}) {
    final existing = _cart[p.id];
    if (existing != null) {
      existing.qty += qty;
    } else {
      _cart[p.id] = CartItem(p: p, qty: qty);
    }
    notifyListeners();
  }

  void incQty(String id) {
    final it = _cart[id];
    if (it == null) return;
    it.qty++;
    notifyListeners();
  }

  void decQty(String id) {
    final it = _cart[id];
    if (it == null) return;
    it.qty--;
    if (it.qty <= 0) _cart.remove(id);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  // Búsqueda / filtros
  void setQuery(String q) {
    _query = q;
    _applyFilters();
  }

  void setCategory(String c) {
    _category = c;
    _applyFilters();
  }

  void setSort(SortBy s) {
    _sortBy = s;
    _applyFilters();
  }

  void _applyFilters() {
    _filtered = _all.where((p) {
      final catOk = _category == 'Todos' || p.category == _category;
      final q = _query.trim().toLowerCase();
      final qOk = q.isEmpty ||
          p.title.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q);
      return catOk && qOk;
    }).toList();

    switch (_sortBy) {
      case SortBy.popular:
        _filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortBy.priceLow:
        _filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortBy.priceHigh:
        _filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
    }
    notifyListeners();
  }

  List<String> get categories =>
      ['Todos', ..._all.map((e) => e.category).toSet()];
}

/// InheritedNotifier minimalista para acceder al estado en el árbol
class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState notifier,
    required Widget child,
  }) : super(notifier: notifier, child: child);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppStateScope>()!.notifier!;
}

/*──────────────────────────────── HOME ────────────────────────────────────*/

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openCart() => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => const CartSheet(),
  );

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tienda'),
        actions: [
          // Icono de Carrito con badge animado
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  onPressed: _openCart,
                  icon: const Icon(Icons.shopping_bag_outlined),
                ),
                Positioned(
                  right: 6,
                  top: 10,
                  child: AnimatedBuilder(
                    animation: app,
                    builder: (_, __) {
                      final n = app.cartCount;
                      if (n == 0) return const SizedBox.shrink();
                      return AnimatedScale(
                        duration: const Duration(milliseconds: 200),
                        scale: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text('$n',
                              style: TextStyle(
                                color: scheme.onPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              )),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // BÚSQUEDA
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _search,
                textInputAction: TextInputAction.search,
                onChanged: app.setQuery,
                decoration: const InputDecoration(
                  hintText: 'Buscar productos...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            // CATEGORÍAS + ORDEN
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: AnimatedBuilder(
                      animation: app,
                      builder: (_, __) => SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: app.categories
                              .map((c) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(c),
                              selected: app.category == c,
                              onSelected: (_) => app.setCategory(c),
                            ),
                          ))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                  PopupMenuButton<SortBy>(
                    initialValue: app.sortBy,
                    onSelected: app.setSort,
                    itemBuilder: (ctx) => const [
                      PopupMenuItem(value: SortBy.popular, child: Text('Popularidad')),
                      PopupMenuItem(value: SortBy.priceLow, child: Text('Precio: menor')),
                      PopupMenuItem(value: SortBy.priceHigh, child: Text('Precio: mayor')),
                    ],
                    child: Row(
                      children: const [
                        Icon(Icons.sort),
                        SizedBox(width: 6),
                        Text('Ordenar'),
                      ],
                    ),
                  )
                ],
              ),
            ),

            // GRID DE PRODUCTOS (con animación de entrada)
            Expanded(
              child: AnimatedBuilder(
                animation: app,
                builder: (_, __) {
                  final items = app.products;
                  if (items.isEmpty) {
                    return const Center(child: Text('Sin resultados'));
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final p = items[i];
                      return _StaggeredFadeIn(
                        delay: Duration(milliseconds: 40 * i),
                        child: ProductCard(product: p),
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

/*─────────────────────────────── PRODUCT CARD ───────────────────────────────*/

class ProductCard extends StatefulWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse =
  AnimationController(vsync: this, duration: const Duration(milliseconds: 180), lowerBound: .7, upperBound: 1);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    final p = widget.product;
    final scheme = Theme.of(context).colorScheme;

    final isFav = app.favorites.contains(p.id);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ProductDetail(product: p)),
      ),
      child: Ink(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              // IMAGEN / HERO
              Hero(
                tag: 'product-${p.id}',
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        colors: p.gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Icon(p.icon, size: 56, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // TÍTULO
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  p.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 4),
              // PRECIO + RATING + FAVORITO
              Row(
                children: [
                  Text('\$${p.price.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Icon(Icons.star_rounded, color: Colors.amber.shade600, size: 18),
                  Text(p.rating.toStringAsFixed(1)),
                  const SizedBox(width: 6),
                  ScaleTransition(
                    scale: _pulse,
                    child: IconButton(
                      tooltip: isFav ? 'Quitar de favoritos' : 'Agregar a favoritos',
                      icon: Icon(isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded),
                      color: isFav ? scheme.primary : null,
                      onPressed: () {
                        _pulse.forward(from: .7);
                        app.toggleFavorite(p);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*────────────────────────────── PRODUCT DETAIL ──────────────────────────────*/

class ProductDetail extends StatefulWidget {
  final Product product;
  const ProductDetail({super.key, required this.product});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  int qty = 1;
  bool added = false;

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    final p = widget.product;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            stretch: true,
            title: Text(p.title),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Hero(
                tag: 'product-${p.id}',
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 56, 16, 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: p.gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(child: Icon(p.icon, size: 96, color: Colors.white)),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, color: Colors.amber.shade600, size: 20),
                      const SizedBox(width: 4),
                      Text('${p.rating} • ${p.category}'),
                      const Spacer(),
                      Text('\$${p.price.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(p.description),
                  const SizedBox(height: 18),
                  Text('Colores', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: p.gradient
                        .map((c) => Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                    ))
                        .toList(),
                  ),
                  const SizedBox(height: 18),
                  Text('Cantidad', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _QtyButton(icon: Icons.remove, onTap: () => setState(() => qty = max(1, qty - 1))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('$qty', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      ),
                      _QtyButton(icon: Icons.add, onTap: () => setState(() => qty++)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // BOTÓN FIJO “AGREGAR AL CARRITO”
      bottomSheet: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [BoxShadow(blurRadius: 12, color: Colors.black.withOpacity(0.08))],
          ),
          child: Row(
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  child: added
                      ? FilledButton.tonalIcon(
                    key: const ValueKey('added'),
                    onPressed: () {},
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Agregado'),
                  )
                      : FilledButton.icon(
                    key: const ValueKey('add'),
                    onPressed: () {
                      AppStateScope.of(context).addToCart(p, qty: qty);
                      setState(() => added = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Agregado ${p.title} x$qty'),
                          action: SnackBarAction(
                            label: 'Ver carrito',
                            onPressed: () => showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              useSafeArea: true,
                              showDragHandle: true,
                              builder: (_) => const CartSheet(),
                            ),
                          ),
                        ),
                      );
                      Future.delayed(const Duration(seconds: 2), () {
                        if (mounted) setState(() => added = false);
                      });
                    },
                    icon: const Icon(Icons.shopping_bag_rounded),
                    label: const Text('Agregar al carrito'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text('\$${(p.price * qty).toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 18),
        ),
      ),
    );
  }
}

/*──────────────────────────────── CART SHEET ───────────────────────────────*/

class CartSheet extends StatelessWidget {
  const CartSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    final scheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: app,
      builder: (_, __) {
        final items = app.cart.values.toList();
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Carrito', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text('Tu carrito está vacío', style: TextStyle(color: scheme.outline)),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final it = items[i];
                      final p = it.p;
                      return ListTile(
                        leading: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(colors: p.gradient),
                          ),
                          child: Icon(p.icon, color: Colors.white),
                        ),
                        title: Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text('\$${p.price.toStringAsFixed(2)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              onPressed: () => app.decQty(p.id),
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text('${it.qty}', style: const TextStyle(fontWeight: FontWeight.w700)),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              onPressed: () => app.incQty(p.id),
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Text('Subtotal', style: TextStyle(color: scheme.outline))),
                  Text('\$${app.subtotal.toStringAsFixed(2)}'),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(child: Text('Impuestos (15%)', style: TextStyle(color: scheme.outline))),
                  Text('\$${app.taxes.toStringAsFixed(2)}'),
                ],
              ),
              const Divider(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Text('Total',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800)),
                  ),
                  Text('\$${app.total.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: items.isEmpty ? null : () {},
                      icon: const Icon(Icons.payment_rounded),
                      label: const Text('Pagar'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: items.isEmpty ? null : app.clearCart,
                    child: const Text('Vaciar'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
          ),
        );
      },
    );
  }
}

/*──────────────────────────── ANIM AUX ─────────────────────────────────────*/

class _StaggeredFadeIn extends StatelessWidget {
  final Widget child;
  final Duration delay;
  const _StaggeredFadeIn({required this.child, this.delay = Duration.zero});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      
      builder: (context, t, _) {
        return Transform.scale(
          scale: 0.95 + 0.05 * t,
          child: Opacity(opacity: t, child: child),
        );
      },
    );
  }
}
