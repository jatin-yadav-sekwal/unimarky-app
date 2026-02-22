import 'package:flutter/material.dart';
import 'package:unimarky/core/network/api_client.dart';

class UploadMaterialScreen extends StatefulWidget {
  const UploadMaterialScreen({super.key});

  @override
  State<UploadMaterialScreen> createState() => _UploadMaterialScreenState();
}

class _UploadMaterialScreenState extends State<UploadMaterialScreen> {
  final _formKey = GlobalKey<FormState>();
  List<String> _departments = [];
  List<String> _years = [];
  List<String> _categories = [];
  String? _department;
  String? _year;
  String? _category;
  final _subjectCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _fileUrlCtrl = TextEditingController();
  bool _submitting = false;
  bool _metaLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadMeta();
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _fileUrlCtrl.dispose();
    super.dispose();
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) { return; }
    setState(() => _submitting = true);
    try {
      await ApiClient.instance.post('/study', data: {
        'department': _department,
        'year': _year,
        'subjectName': _subjectCtrl.text.trim(),
        'category': _category,
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null,
        'fileUrl': _fileUrlCtrl.text.trim().isNotEmpty ? _fileUrlCtrl.text.trim() : null,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Material uploaded successfully!'), backgroundColor: Colors.green));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) { setState(() => _submitting = false); }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_metaLoaded) {
      return Scaffold(appBar: AppBar(title: const Text('Upload Material')), body: const Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Study Material')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _department,
                decoration: const InputDecoration(labelText: 'Department *', border: OutlineInputBorder()),
                items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d, overflow: TextOverflow.ellipsis))).toList(),
                validator: (v) => v == null ? 'Required' : null,
                onChanged: (v) => setState(() => _department = v),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _year,
                decoration: const InputDecoration(labelText: 'Year *', border: OutlineInputBorder()),
                items: _years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                validator: (v) => v == null ? 'Required' : null,
                onChanged: (v) => setState(() => _year = v),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category *', border: OutlineInputBorder()),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c.replaceAll('_', ' ').split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ')))).toList(),
                validator: (v) => v == null ? 'Required' : null,
                onChanged: (v) => setState(() => _category = v),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _subjectCtrl,
                decoration: const InputDecoration(labelText: 'Subject Name *', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title *', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description (optional)', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _fileUrlCtrl,
                decoration: const InputDecoration(labelText: 'File URL (optional)', border: OutlineInputBorder(), hintText: 'Paste Google Drive / Supabase link'),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Upload Material'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
