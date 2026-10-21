import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api/api_client.dart';
import '../../data/catalog_repository.dart';
import 'package:uuid/uuid.dart';
import '../../data/nutrition_repository.dart';
import '../../models/daily_ration.dart';
import '../../models/product.dart';
import '../profile/profile_edit_screen.dart';

void showNutritionError(BuildContext context, String message) =>
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
Future<bool> confirmNutritionDelete(
  BuildContext context,
  String message,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удаление'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    ) ??
    false;
double? _parse(String value) =>
    double.tryParse(value.trim().replaceAll(',', '.'));

class ProductCatalogScreen extends StatefulWidget {
  const ProductCatalogScreen({super.key, required this.repository});
  final NutritionRepository repository;
  @override
  State<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen> {
  late Future<List<Product>> _data = widget.repository.products();
  String _query = '';
  bool _importing = false;
  Future<void> _import() async {
    final api = context.read<ApiClient?>();
    if (api == null) return;
    setState(() => _importing = true);
    try {
      final count = await CatalogRepository(
        widget.repository.database,
        api,
      ).importProducts(_query);
      if (mounted) {
        _refresh();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              count == 0
                  ? 'Каталог пуст. Добавьте свой продукт или повторите после импорта на сервере.'
                  : 'Продукты сохранены для работы офлайн',
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        showNutritionError(
          context,
          'Каталог недоступен. Локальные продукты сохранены.',
        );
      }
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  void _refresh() => setState(() {
    _data = widget.repository.products();
  });
  Future<void> _edit([Product? product]) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            ProductEditScreen(repository: widget.repository, initial: product),
      ),
    );
    if (mounted) _refresh();
  }

  Future<void> _delete(Product product) async {
    if (!await confirmNutritionDelete(
          context,
          'Удалить «${product.name}» из каталога? История питания сохранится.',
        ) ||
        !mounted) {
      return;
    }
    try {
      await widget.repository.deleteProduct(product.id);
      if (mounted) _refresh();
    } catch (_) {
      if (mounted) showNutritionError(context, 'Не удалось удалить продукт.');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Продукты'),
      actions: [
        IconButton(
          tooltip: 'Загрузить из каталога',
          onPressed: _importing ? null : _import,
          icon: const Icon(Icons.cloud_download_outlined),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      heroTag: 'product-create',
      tooltip: 'Новый продукт',
      onPressed: () => _edit(),
      child: const Icon(Icons.add),
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Поиск продукта',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) =>
                setState(() => _query = value.trim().toLowerCase()),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Product>>(
            future: _data,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: TextButton(
                    onPressed: _refresh,
                    child: const Text('Ошибка загрузки. Повторить'),
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final products = snapshot.data!
                  .where((p) => p.name.toLowerCase().contains(_query))
                  .toList();
              if (products.isEmpty) {
                return const Center(
                  child: Text('Продукты не найдены. Добавьте свой продукт.'),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 90),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final p = products[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        child: Icon(
                          Icons.local_grocery_store_outlined,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      title: Text(p.name),
                      subtitle: Text(
                        'На 100 г: ${p.calories} ккал · Б ${p.protein} · Ж ${p.fat} · У ${p.carbs}',
                      ),
                      onTap: () => _edit(p),
                      trailing: IconButton(
                        tooltip: 'Удалить продукт',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _delete(p),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    ),
  );
}

class ProductEditScreen extends StatefulWidget {
  const ProductEditScreen({super.key, required this.repository, this.initial});
  final NutritionRepository repository;
  final Product? initial;
  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial?.name ?? '');
  late final _values =
      [
            widget.initial?.calories,
            widget.initial?.protein,
            widget.initial?.fat,
            widget.initial?.carbs,
          ]
          .map((value) => TextEditingController(text: value?.toString() ?? ''))
          .toList();
  bool _busy = false;
  String? _error;
  @override
  void dispose() {
    _name.dispose();
    for (final controller in _values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final p = Product(
        id: widget.initial?.id ?? const Uuid().v4(),
        name: _name.text.trim(),
        calories: _parse(_values[0].text)!,
        protein: _parse(_values[1].text)!,
        fat: _parse(_values[2].text)!,
        carbs: _parse(_values[3].text)!,
      );
      await widget.repository.saveProduct(p);
      if (mounted) Navigator.pop(context);
    } on ArgumentError catch (error) {
      if (mounted) setState(() => _error = error.message.toString());
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Не удалось сохранить продукт. Повторите попытку.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.initial == null ? 'Новый продукт' : 'Изменить продукт',
      ),
    ),
    body: AbsorbPointer(
      absorbing: _busy,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Пищевая ценность на 100 г. Для готового блюда укажите значения на 100 г готового блюда.',
              ),
              TextFormField(
                controller: _name,
                maxLength: 120,
                decoration: const InputDecoration(
                  labelText: 'Название продукта',
                ),
                validator: (value) =>
                    (value ?? '').trim().isEmpty ? 'Введите название' : null,
              ),
              for (var i = 0; i < 4; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextFormField(
                    controller: _values[i],
                    decoration: InputDecoration(
                      labelText: [
                        'Калории, ккал',
                        'Белки, г',
                        'Жиры, г',
                        'Углеводы, г',
                      ][i],
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (text) {
                      final value = _parse(text ?? '');
                      final max = i == 0 ? 900 : 100.1;
                      return value == null ||
                              !value.isFinite ||
                              value < 0 ||
                              value > max
                          ? 'Введите число от 0 до $max'
                          : null;
                    },
                  ),
                ),
              if (_error != null)
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _busy ? null : _save,
                child: Text(_busy ? 'Сохранение…' : 'Сохранить продукт'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class EntryEditScreen extends StatefulWidget {
  const EntryEditScreen({
    super.key,
    required this.repository,
    required this.day,
    required this.kind,
    this.initial,
  });
  final NutritionRepository repository;
  final DateTime day;
  final MealKind kind;
  final RationEntry? initial;
  @override
  State<EntryEditScreen> createState() => _EntryEditScreenState();
}

class _EntryEditScreenState extends State<EntryEditScreen> {
  final _form = GlobalKey<FormState>();
  late final _grams = TextEditingController(
    text: widget.initial?.grams.toString() ?? '100',
  );
  late DateTime _day = widget.day;
  late MealKind _kind = widget.kind;
  late String? _productId = widget.initial?.product.id;
  late Future<List<Product>> _products = widget.repository.products();
  bool _busy = false;
  String? _error;
  @override
  void dispose() {
    _grams.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.repository.saveEntry(
        id: widget.initial?.id,
        productId: _productId!,
        grams: _parse(_grams.text)!,
        day: _day,
        kind: _kind,
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Не удалось сохранить запись. Проверьте продукт и повторите попытку.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.initial == null ? 'Добавить еду' : 'Изменить запись'),
    ),
    body: AbsorbPointer(
      absorbing: _busy,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FutureBuilder<List<Product>>(
                future: _products,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return TextButton(
                      onPressed: () => setState(() {
                        _products = widget.repository.products();
                      }),
                      child: const Text('Повторить загрузку продуктов'),
                    );
                  }
                  if (!snapshot.hasData) return const LinearProgressIndicator();
                  final products = [...snapshot.data!];
                  final old = widget.initial?.product;
                  if (old != null && !products.any((p) => p.id == old.id)) {
                    products.add(old);
                  }
                  return DropdownButtonFormField<String>(
                    initialValue: _productId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Продукт'),
                    items: products
                        .map(
                          (p) => DropdownMenuItem(
                            value: p.id,
                            child: Text(
                              p.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (id) => setState(() => _productId = id),
                    validator: (_) =>
                        _productId == null ? 'Выберите продукт' : null,
                  );
                },
              ),
              TextButton.icon(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          ProductEditScreen(repository: widget.repository),
                    ),
                  );
                  if (mounted) {
                    setState(() {
                      _products = widget.repository.products();
                    });
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Создать продукт'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _grams,
                decoration: const InputDecoration(labelText: 'Масса, г'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (text) {
                  final grams = _parse(text ?? '');
                  return grams == null ||
                          !grams.isFinite ||
                          grams <= 0 ||
                          grams > 10000
                      ? 'Введите массу больше 0 и не более 10 000 г'
                      : null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<MealKind>(
                initialValue: _kind,
                decoration: const InputDecoration(labelText: 'Приём пищи'),
                items: MealKind.values
                    .map(
                      (v) => DropdownMenuItem(value: v, child: Text(v.label)),
                    )
                    .toList(),
                onChanged: (kind) => setState(() => _kind = kind!),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_month),
                label: Text(formatProfileDate(_day)),
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _day,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100, 12, 31),
                  );
                  if (date != null && mounted) setState(() => _day = date);
                },
              ),
              if (widget.initial != null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'При изменении массы и даты сохраняется пищевая ценность на момент добавления. Для другого продукта берутся значения из каталога.',
                  ),
                ),
              if (_error != null)
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _busy ? null : _save,
                child: Text(_busy ? 'Сохранение…' : 'Сохранить запись'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
