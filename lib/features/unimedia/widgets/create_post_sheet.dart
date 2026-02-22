import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unimarky/core/network/api_client.dart';

/// Bottom sheet for creating a post, event, or announcement
class CreatePostSheet extends StatefulWidget {
  final VoidCallback onCreated;
  const CreatePostSheet({super.key, required this.onCreated});
  @override
  State<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<CreatePostSheet> {
  final _contentC = TextEditingController();
  final _titleC = TextEditingController();
  final _hostedByC = TextEditingController();
  String _type = 'post';
  DateTime? _eventDate;
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
    final path = 'social/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final bytes = await _image!.readAsBytes();
    await supabase.storage.from('uploads').uploadBinary(path, bytes, fileOptions: const FileOptions(contentType: 'image/jpeg'));
    return supabase.storage.from('uploads').getPublicUrl(path);
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
    if (date != null) setState(() => _eventDate = date);
  }

  Future<void> _submit() async {
    if (_contentC.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final imageUrl = await _uploadImage();
      await ApiClient.instance.post('/social', data: {
        'content': _contentC.text.trim(),
        'type': _type,
        if (_titleC.text.trim().isNotEmpty) 'title': _titleC.text.trim(),
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (_eventDate != null) 'eventDate': _eventDate!.toIso8601String(),
        if (_hostedByC.text.trim().isNotEmpty) 'hostedBy': _hostedByC.text.trim(),
      });
      if (mounted) {
        Navigator.pop(context);
        widget.onCreated();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Handle
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(
          color: theme.colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),

        Text('Create Post', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        // Type selector
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'post', label: Text('Post'), icon: Icon(Icons.edit, size: 16)),
            ButtonSegment(value: 'event', label: Text('Event'), icon: Icon(Icons.event, size: 16)),
            ButtonSegment(value: 'announcement', label: Text('News'), icon: Icon(Icons.campaign, size: 16)),
          ],
          selected: {_type},
          onSelectionChanged: (s) => setState(() => _type = s.first),
        ),
        const SizedBox(height: 12),

        if (_type != 'post') ...[
          TextField(controller: _titleC, decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder(), isDense: true)),
          const SizedBox(height: 10),
        ],

        TextField(
          controller: _contentC, maxLines: 3,
          decoration: const InputDecoration(hintText: "What's on your mind?", border: OutlineInputBorder()),
        ),
        const SizedBox(height: 10),

        if (_type == 'event') ...[
          Row(children: [
            Expanded(child: TextField(controller: _hostedByC,
              decoration: const InputDecoration(labelText: 'Hosted by', border: OutlineInputBorder(), isDense: true))),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today, size: 16),
              label: Text(_eventDate != null ? '${_eventDate!.day}/${_eventDate!.month}' : 'Date'),
            ),
          ]),
          const SizedBox(height: 10),
        ],

        // Image & Submit
        Row(children: [
          IconButton(onPressed: _pickImage,
            icon: Icon(_image != null ? Icons.image : Icons.add_photo_alternate,
              color: _image != null ? theme.colorScheme.primary : null)),
          if (_image != null) Text('Photo added', style: TextStyle(fontSize: 12, color: theme.colorScheme.primary)),
          const Spacer(),
          FilledButton(
            onPressed: _loading ? null : _submit,
            child: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Post'),
          ),
        ]),
      ]),
    );
  }
}
