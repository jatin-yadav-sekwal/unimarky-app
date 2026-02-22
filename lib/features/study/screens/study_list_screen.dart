import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unimarky/core/network/api_client.dart';
import '../models/study_models.dart';
import '../widgets/study_material_card.dart';

class StudyListScreen extends StatefulWidget {
  const StudyListScreen({super.key});

  @override
  State<StudyListScreen> createState() => _StudyListScreenState();
}

class _StudyListScreenState extends State<StudyListScreen> {
  List<String> _departments = [];
  List<String> _years = [];
  List<String> _categories = [];
  String? _selectedDept;
  String? _selectedYear;
  String? _selectedCategory;
  List<StudyMaterial> _materials = [];
  bool _isLoading = false;
  bool _metaLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadMeta();
  }

  Future<void> _loadMeta() async {
    try {
      final data = await ApiClient.instance.get('/study/departments');
      setState(() {
        _departments = List<String>.from(data['departments'] ?? []);
        _years = List<String>.from(data['years'] ?? []);
        _categories = List<String>.from(data['categories'] ?? []);
        _metaLoaded = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load filters: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _loadMaterials() async {
    if (_selectedDept == null || _selectedYear == null) { return; }
    setState(() => _isLoading = true);
    try {
      final catP = _selectedCategory != null ? '&category=${Uri.encodeComponent(_selectedCategory!)}' : '';
      final d = Uri.encodeComponent(_selectedDept!);
      final y = Uri.encodeComponent(_selectedYear!);
      final data = await ApiClient.instance.get('/study?department=$d&year=$y$catP');
      final list = data is List ? data : [];
      setState(() {
        _materials = list.map((e) => StudyMaterial.fromJson(e)).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load materials: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) { setState(() => _isLoading = false); }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (!_metaLoaded) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        // Filters
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedDept,
                decoration: const InputDecoration(labelText: 'Department', border: OutlineInputBorder(), isDense: true),
                items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d, overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (v) {
                  setState(() => _selectedDept = v);
                  _loadMaterials();
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedYear,
                decoration: const InputDecoration(labelText: 'Year', border: OutlineInputBorder(), isDense: true),
                items: _years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                onChanged: (v) {
                  setState(() => _selectedYear = v);
                  _loadMaterials();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        // Category filter chips
        if (_categories.isNotEmpty)
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                if (i == 0) {
                  return FilterChip(
                    label: const Text('All'),
                    selected: _selectedCategory == null,
                    onSelected: (_) { setState(() => _selectedCategory = null); _loadMaterials(); },
                  );
                }
                final cat = _categories[i - 1];
                return FilterChip(
                  label: Text(categoryLabels[cat] ?? cat),
                  selected: _selectedCategory == cat,
                  onSelected: (_) { setState(() => _selectedCategory = cat); _loadMaterials(); },
                );
              },
            ),
          ),
        const SizedBox(height: 8),
        // Results
        Expanded(
          child: _selectedDept == null || _selectedYear == null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.school, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('Select department & year to browse', style: theme.textTheme.titleMedium),
                ]))
              : _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _materials.isEmpty
                      ? Center(child: Text('No materials found', style: theme.textTheme.titleMedium))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _materials.length,
                          itemBuilder: (_, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: StudyMaterialCard(
                              material: _materials[i],
                              onTap: () {
                                final url = _materials[i].fileUrl;
                                if (url != null && url.isNotEmpty) {
                                  Clipboard.setData(ClipboardData(text: url));
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File link copied to clipboard')));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No file link available')));
                                }
                              },
                            ),
                          ),
                        ),
        ),
      ],
    );
  }
}
