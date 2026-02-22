import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unimarky/core/network/api_client.dart';
import 'package:unimarky/core/utils/image_compressor.dart';
import 'package:unimarky/features/lostfound/models/lostfound_item.dart';

class EditReportScreen extends StatefulWidget {
  final String itemId;
  const EditReportScreen({super.key, required this.itemId});

  @override
  State<EditReportScreen> createState() => _EditReportScreenState();
}

class _EditReportScreenState extends State<EditReportScreen> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'lost';
  final _nameC = TextEditingController();
  final _descC = TextEditingController();
  final _locC = TextEditingController();
  String _category = 'electronics';
  
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  
  XFile? _newImage;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchReportDetails();
  }

  Future<void> _fetchReportDetails() async {
    try {
      final data = await ApiClient.instance.get('/lost-found/${widget.itemId}');
      final item = LostFoundItem.fromJson(data);
      
      setState(() {
        _type = item.type;
        _nameC.text = item.itemName;
        _descC.text = item.description;
        _locC.text = item.location ?? '';
        final catId = data['categoryId'] as String?;
        final catExists = lostFoundCategories.any((c) => c['value'] == catId);
        _category = catExists && catId != null ? catId : 'electronics';
        _existingImageUrl = item.imageUrl;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load report: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    var picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 80);
    if (picked != null) {
      picked = await ImageCompressor.compressImage(picked);
      setState(() => _newImage = picked);
    }
  }

  Future<String?> _uploadImage() async {
    if (_newImage == null) return null;
    final supabase = Supabase.instance.client;
    final uid = supabase.auth.currentUser?.id ?? 'unknown';
    final path = 'lostfound/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final bytes = await _newImage!.readAsBytes();
    await supabase.storage.from('uploads').uploadBinary(path, bytes, fileOptions: const FileOptions(contentType: 'image/jpeg'));
    return supabase.storage.from('uploads').getPublicUrl(path);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    
    try {
      String? imageUrl = _existingImageUrl;
      if (_newImage != null) {
        imageUrl = await _uploadImage();
      }

      await ApiClient.instance.patch('/lost-found/${widget.itemId}', data: {
        'type': _type,
        'itemName': _nameC.text.trim(),
        'description': _descC.text.trim(),
        'location': _locC.text.trim(),
        'categoryId': _category,
        if (imageUrl != null) 'imageUrl': imageUrl,
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report updated!')));
        context.pop(true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Report')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Report')),
        body: Center(child: Text(_error!, style: const TextStyle(color: Colors.red))),
      );
    }

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Report')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image picker
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180, width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                clipBehavior: Clip.antiAlias,
                child: _newImage != null
                    ? Image.file(File(_newImage!.path), fit: BoxFit.cover)
                    : (_existingImageUrl != null
                        ? Image.network(_existingImageUrl!, fit: BoxFit.cover)
                        : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.add_photo_alternate, size: 40, color: theme.colorScheme.onSurfaceVariant),
                            const SizedBox(height: 8),
                            Text('Change Photo', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                          ])
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Type
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'lost', label: Text('Lost')),
                ButtonSegment(value: 'found', label: Text('Found')),
              ],
              selected: {_type},
              onSelectionChanged: (v) => setState(() => _type = v.first),
            ),
            const SizedBox(height: 16),

            TextFormField(controller: _nameC, decoration: const InputDecoration(labelText: 'Item Name', border: OutlineInputBorder()),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
            const SizedBox(height: 12),

            TextFormField(controller: _descC, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
              maxLines: 3, validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
            const SizedBox(height: 12),

            TextFormField(controller: _locC, decoration: InputDecoration(labelText: 'Location', border: const OutlineInputBorder(),
              hintText: _type == 'lost' ? 'Where did you lose it?' : 'Where did you find it?'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
            const SizedBox(height: 12),

            // Category
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
              items: lostFoundCategories.where((c) => c['value'] != 'all').map((c) =>
                DropdownMenuItem(value: c['value'], child: Text(c['label']!))).toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity, height: 48,
              child: FilledButton(
                onPressed: _isSaving ? null : _submit,
                child: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const lostFoundCategories = [
  {'value': 'all', 'label': 'All Categories'},
  {'value': 'electronics', 'label': 'Electronics'},
  {'value': 'documents', 'label': 'Documents'},
  {'value': 'clothing', 'label': 'Clothing'},
  {'value': 'keys', 'label': 'Keys'},
  {'value': 'accessories', 'label': 'Accessories'},
  {'value': 'other', 'label': 'Other'},
];
