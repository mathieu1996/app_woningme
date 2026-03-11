import 'package:flutter/material.dart';

class CityPickerField extends StatelessWidget {
  final String? value;
  final List<String> steden;
  final bool hasError;
  final String? errorText;
  final String label;
  final ValueChanged<String?> onChanged;

  const CityPickerField({
    super.key,
    required this.value,
    required this.steden,
    required this.hasError,
    required this.errorText,
    required this.label,
    required this.onChanged,
  });

  Future<void> _openPicker(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => CityPickerSheet(steden: steden, selected: value),
    );
    if (result != null) onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = hasError
        ? theme.colorScheme.error
        : const Color(0xFFBDBDBD);
    final labelColor = hasError
        ? theme.colorScheme.error
        : Colors.black54;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: steden.isEmpty ? null : () => _openPicker(context),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.location_city, color: labelColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value ?? label,
                    style: TextStyle(
                      fontSize: 16,
                      color: value != null ? Colors.black87 : Colors.black45,
                    ),
                  ),
                ),
                if (value != null)
                  GestureDetector(
                    onTap: () => onChanged(null),
                    child: const Icon(Icons.clear, size: 18, color: Colors.black45),
                  )
                else if (steden.isEmpty)
                  const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(Icons.keyboard_arrow_down, color: Colors.black45),
              ],
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4),
            child: Text(errorText!,
                style: TextStyle(fontSize: 12, color: theme.colorScheme.error)),
          ),
      ],
    );
  }
}

class CityPickerSheet extends StatefulWidget {
  final List<String> steden;
  final String? selected;

  const CityPickerSheet({super.key, required this.steden, this.selected});

  @override
  State<CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<CityPickerSheet> {
  final _searchController = TextEditingController();
  late List<String> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = widget.steden;
  }

  void _onSearch(String q) {
    setState(() {
      _filtered = q.isEmpty
          ? widget.steden
          : widget.steden
              .where((s) => s.toLowerCase().contains(q.toLowerCase()))
              .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (_, controller) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Zoek stad…',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              controller: controller,
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final city = _filtered[i];
                final selected = city == widget.selected;
                return ListTile(
                  title: Text(city),
                  trailing: selected
                      ? const Icon(Icons.check, color: Colors.black87)
                      : null,
                  selected: selected,
                  onTap: () => Navigator.of(context).pop(city),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
