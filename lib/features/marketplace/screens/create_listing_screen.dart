import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unimarky/core/network/api_client.dart';
import 'package:unimarky/features/marketplace/models/marketplace_item.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});
  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleC = TextEditingController();
  final _descC = TextEditingController();
  final _priceC = TextEditingController();
  final _yearC = TextEditingController();
  String _category = 'electronics';
  String _condition = 'good';
  bool _negotiable = false;
  bool _loading = false;
  XFile? _image;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 80);
    if (picked != null) setState(() => _image = picked);
  }

  Future<String?> _uploadImage() async {
    if (_image == null) return null;
    final supabase = Supabase.instance.client;
    final uid = supabase.auth.currentUser?.id ?? 'unknown';
    final path = 'marketplace/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final bytes = await _image!.readAsBytes();
    await supabase.storage.from('uploads').uploadBinary(path, bytes, fileOptions: const FileOptions(contentType: 'image/jpeg'));
    return supabase.storage.from('uploads').getPublicUrl(path);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final imageUrl = await _uploadImage();
      await ApiClient.instance.post('/marketplace', data: {
        'title': _titleC.text.trim(),
        'description': _descC.text.trim(),
        'price': _priceC.text.trim(),
        'category': _category,
        'condition': _condition,
        'isNegotiable': _negotiable,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (_yearC.text.trim().isNotEmpty) 'manufacturedYear': _yearC.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing created!')));
        context.pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('List an Item')),
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
                child: _image != null
                    ? Image.file(File(_image!.path), fit: BoxFit.cover)
                    : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.add_photo_alternate, size: 40, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(height: 8),
                        Text('Add Photo', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                      ]),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(controller: _titleC, decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
            const SizedBox(height: 12),

            TextFormField(controller: _descC, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
              maxLines: 3, validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
            const SizedBox(height: 12),

            TextFormField(controller: _priceC, decoration: const InputDecoration(labelText: 'Price (₹)', border: OutlineInputBorder(), prefixText: '₹ '),
              keyboardType: TextInputType.number, validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
            const SizedBox(height: 12),

            // Category
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
              items: marketplaceCategories.where((c) => c['value'] != 'all').map((c) =>
                DropdownMenuItem(value: c['value'], child: Text(c['label']!))).toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 12),

            // Condition
            DropdownButtonFormField<String>(
              value: _condition,
              decoration: const InputDecoration(labelText: 'Condition', border: OutlineInputBorder()),
              items: conditionOptions.map((c) =>
                DropdownMenuItem(value: c['value'], child: Text(c['label']!))).toList(),
              onChanged: (v) => setState(() => _condition = v!),
            ),
            const SizedBox(height: 12),

            TextFormField(controller: _yearC, decoration: const InputDecoration(labelText: 'Year (optional)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number),
            const SizedBox(height: 12),

            SwitchListTile(
              title: const Text('Price is negotiable'),
              value: _negotiable,
              onChanged: (v) => setState(() => _negotiable = v),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity, height: 48,
              child: FilledButton(
                onPressed: _loading ? null : _submit,
                child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('List Item'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
