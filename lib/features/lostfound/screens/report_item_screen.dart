import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unimarky/core/network/api_client.dart';
import 'package:unimarky/core/utils/image_compressor.dart';

class ReportItemScreen extends StatefulWidget {
  const ReportItemScreen({super.key});
  @override
  State<ReportItemScreen> createState() => _ReportItemScreenState();
}

class _ReportItemScreenState extends State<ReportItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameC = TextEditingController();
  final _descC = TextEditingController();
  final _locationC = TextEditingController();
  String _type = 'lost';
  bool _loading = false;
  XFile? _image;

  Future<void> _pickImage() async {
    var picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 80);
    if (picked != null) {
      picked = await ImageCompressor.compressImage(picked);
      setState(() => _image = picked);
    }
  }

  Future<String?> _uploadImage() async {
    if (_image == null) return null;
    final supabase = Supabase.instance.client;
    final uid = supabase.auth.currentUser?.id ?? 'unknown';
    final path = 'lostfound/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final bytes = await _image!.readAsBytes();
    await supabase.storage.from('uploads').uploadBinary(path, bytes, fileOptions: const FileOptions(contentType: 'image/jpeg'));
    return supabase.storage.from('uploads').getPublicUrl(path);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final imageUrl = await _uploadImage();
      await ApiClient.instance.post('/lostfound', data: {
        'itemName': _nameC.text.trim(),
        'description': _descC.text.trim(),
        'type': _type,
        if (_locationC.text.trim().isNotEmpty) 'location': _locationC.text.trim(),
        if (imageUrl != null) 'imageUrl': imageUrl,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item reported!')));
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
      appBar: AppBar(title: const Text('Report Item')),
      body: Form(key: _formKey, child: ListView(padding: const EdgeInsets.all(16), children: [
        // Image
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 180, width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.outlineVariant)),
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

        // Type toggle
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'lost', label: Text('Lost'), icon: Icon(Icons.sentiment_dissatisfied)),
            ButtonSegment(value: 'found', label: Text('Found'), icon: Icon(Icons.sentiment_satisfied)),
          ],
          selected: {_type},
          onSelectionChanged: (s) => setState(() => _type = s.first),
        ),
        const SizedBox(height: 16),

        TextFormField(controller: _nameC, decoration: const InputDecoration(labelText: 'Item Name', border: OutlineInputBorder()),
          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
        const SizedBox(height: 12),

        TextFormField(controller: _descC, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
          maxLines: 3, validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
        const SizedBox(height: 12),

        TextFormField(controller: _locationC,
          decoration: const InputDecoration(labelText: 'Location (optional)', border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_on_outlined))),
        const SizedBox(height: 20),

        SizedBox(width: double.infinity, height: 48,
          child: FilledButton(
            onPressed: _loading ? null : _submit,
            child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Report Item'),
          )),
      ])),
    );
  }
}
