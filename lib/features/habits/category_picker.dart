import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_db.dart';
import '../../data/repositories/category_repository.dart';
import 'habit_categories.dart';

/// Chip-row category picker. Renders preset categories from [HabitCategory]
/// plus any user-added ones from the [UserCategories] table. Tapping the "+
/// New" chip opens a dialog to add a custom label.
class CategoryPicker extends ConsumerWidget {
  const CategoryPicker({
    super.key,
    required this.selectedId,
    required this.onChanged,
  });

  /// Stored value on the habit row. Either a [HabitCategory.id] or the
  /// uuid of a [UserCategory] row.
  final String selectedId;
  final ValueChanged<String> onChanged;

  Future<void> _addNew(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController();
    try {
      final label = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('New category'),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'e.g. Reading, Cooking, Study',
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(null),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.of(ctx).pop(ctrl.text),
                child: const Text('Add')),
          ],
        ),
      );
      if (label == null || label.trim().isEmpty) return;
      final id = await ref
          .read(categoryRepositoryProvider)
          .create(label.trim());
      onChanged(id);
    } finally {
      ctrl.dispose();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userCats =
        ref.watch(userCategoriesStreamProvider).value ?? const [];
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final c in HabitCategory.values)
          ChoiceChip(
            label: Text(c.label),
            selected: selectedId == c.id,
            onSelected: (_) => onChanged(c.id),
          ),
        for (final uc in userCats)
          ChoiceChip(
            avatar: const Icon(Icons.bookmark_outline, size: 16),
            label: Text(uc.label),
            selected: selectedId == uc.id,
            onSelected: (_) => onChanged(uc.id),
          ),
        ActionChip(
          avatar: const Icon(Icons.add, size: 16),
          label: const Text('New'),
          onPressed: () => _addNew(context, ref),
        ),
      ],
    );
  }
}
