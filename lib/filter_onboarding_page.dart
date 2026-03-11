import 'package:flutter/material.dart';
import 'package:woonme/l10n/app_localizations.dart';
import 'package:woonme/services/api_service.dart';
import 'package:woonme/widgets/city_picker.dart';

const _radii = [5.0, 10.0, 25.0, 50.0];

class FilterOnboardingPage extends StatefulWidget {
  /// Wordt aangeroepen nadat het filter is opgeslagen. Wanneer null,
  /// wordt Navigator.pop gebruikt (bijv. vanuit de registratiestroom).
  final VoidCallback? onComplete;

  const FilterOnboardingPage({super.key, this.onComplete});

  @override
  State<FilterOnboardingPage> createState() => _FilterOnboardingPageState();
}

class _FilterOnboardingPageState extends State<FilterOnboardingPage> {
  String? _selectedCity;
  List<String> _steden = [];
  final _minPrijsController = TextEditingController();
  final _maxPrijsController = TextEditingController();
  final _minOppController = TextEditingController();
  double _radiusKm = 10.0;
  int? _minKamers;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    ApiService.getSteden().then((s) {
      if (mounted) setState(() => _steden = s);
    });
  }

  @override
  void dispose() {
    _minPrijsController.dispose();
    _maxPrijsController.dispose();
    _minOppController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final city = _selectedCity;
    final minPrijs = int.tryParse(_minPrijsController.text.trim());
    final maxPrijs = int.tryParse(_maxPrijsController.text.trim());
    final minOpp = int.tryParse(_minOppController.text.trim());

    if ((city == null || city.isEmpty) &&
        minPrijs == null &&
        maxPrijs == null &&
        _minKamers == null &&
        minOpp == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.filterErrorAtLeastOne)),
      );
      return;
    }

    final parts = <String>[];
    if (city != null && city.isNotEmpty) parts.add('$city + ${_radiusKm.toInt()}');
    if (minPrijs != null && maxPrijs != null) {
      parts.add('€$minPrijs–€$maxPrijs');
    } else if (minPrijs != null) {
      parts.add(l10n.filterFromPrice(minPrijs));
    } else if (maxPrijs != null) {
      parts.add(l10n.filterUpToPrice(maxPrijs));
    }
    if (_minKamers != null) {
      parts.add(l10n.filterRooms('$_minKamers${_minKamers == 4 ? '+' : ''}'));
    }
    if (minOpp != null) parts.add('$minOpp m²+');
    final label =
        parts.isEmpty ? l10n.filterDefaultLabel : parts.join(', ');

    setState(() => _isSaving = true);
    try {
      await ApiService.createSavedSearch(
        label: label,
        city: city,
        radiusKm: city != null ? _radiusKm : null,
        minPrijs: minPrijs,
        maxPrijs: maxPrijs,
        minKamers: _minKamers,
        minOpp: minOpp,
      );
      if (mounted) {
        if (widget.onComplete != null) {
          widget.onComplete!();
        } else {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'.replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
              child: Column(
                children: [
                  const Icon(Icons.favorite,
                      size: 56, color: Colors.pinkAccent),
                  const SizedBox(height: 16),
                  Text(
                    l10n.filterOnboardingTitle,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.filterOnboardingDesc,
                    style: const TextStyle(
                        fontSize: 15, color: Colors.black54, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // ── Formulier ───────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stad
                    CityPickerField(
                      value: _selectedCity,
                      steden: _steden,
                      hasError: false,
                      errorText: null,
                      label: l10n.filterCityLabel,
                      onChanged: (city) => setState(() => _selectedCity = city),
                    ),
                    const SizedBox(height: 12),

                    // Straal
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Text(l10n.filterRadiusLabel,
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black54)),
                          const SizedBox(width: 8),
                          ..._radii.map((r) => Padding(
                                padding:
                                    const EdgeInsets.only(right: 6),
                                child: ChoiceChip(
                                  label: Text('${r.toInt()} km'),
                                  selected: _radiusKm == r,
                                  onSelected: (_) =>
                                      setState(() => _radiusKm = r),
                                ),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Huurprijs
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _minPrijsController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: l10n.filterMinRentLabel,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _maxPrijsController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: l10n.filterMaxRentLabel,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Min. kamers
                    Text(l10n.filterMinRoomsLabel,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black54)),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final k in [1, 2, 3, 4])
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                label: Text(k == 4 ? '4+' : '$k'),
                                selected: _minKamers == k,
                                onSelected: (_) => setState(() =>
                                    _minKamers = _minKamers == k ? null : k),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Min. oppervlakte
                    TextField(
                      controller: _minOppController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.filterMinSizeLabel,
                        prefixIcon:
                            const Icon(Icons.square_foot_outlined),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Knoppen ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _save,
                  style: FilledButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: 15)),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(l10n.filterSaveButton,
                          style: const TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
