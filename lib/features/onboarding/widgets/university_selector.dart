import 'package:flutter/material.dart';

/// Searchable university dropdown — matches web's UniversitySelector.
class UniversitySelector extends StatefulWidget {
  final String? value;
  final ValueChanged<String> onChanged;

  const UniversitySelector({
    super.key,
    this.value,
    required this.onChanged,
  });

  @override
  State<UniversitySelector> createState() => _UniversitySelectorState();
}

class _UniversitySelectorState extends State<UniversitySelector> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _showSuggestions = false;
  List<String> _filtered = [];

  static const _universities = [
    // Featured
    'Central University of Haryana',
    // IITs
    'IIT Bombay',
    'IIT Delhi',
    'IIT Madras',
    'IIT Kanpur',
    'IIT Kharagpur',
    'IIT Roorkee',
    'IIT Hyderabad',
    // Central Universities
    'University of Delhi',
    'Jawaharlal Nehru University (JNU)',
    'Banaras Hindu University (BHU)',
    'Aligarh Muslim University (AMU)',
    'Jamia Millia Islamia',
    'Central University of Punjab',
    'Central University of Rajasthan',
    'Central University of Kashmir',
    // NITs
    'NIT Trichy',
    'NIT Warangal',
    'NIT Surathkal',
    'NIT Kurukshetra',
    // State Universities
    'Anna University',
    'Savitribai Phule Pune University',
    'University of Mumbai',
    'University of Calcutta',
    'Osmania University',
    'Panjab University',
    'Maharshi Dayanand University (MDU)',
    'Kurukshetra University',
    // Private Universities
    'BITS Pilani',
    'Manipal Academy of Higher Education',
    'Amity University',
    'VIT Vellore',
    'SRM Institute of Science and Technology',
    'Lovely Professional University (LPU)',
    'Chandigarh University',
    'Shiv Nadar University',
    'Ashoka University',
    'Thapar Institute of Engineering',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.value != null) _controller.text = widget.value!;
    _filtered = _universities;

    _focusNode.addListener(() {
      setState(() => _showSuggestions = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _filter(String query) {
    setState(() {
      _filtered = _universities
          .where((u) => u.toLowerCase().contains(query.toLowerCase()))
          .toList();
      _showSuggestions = true;
    });
  }

  void _select(String university) {
    _controller.text = university;
    widget.onChanged(university);
    _focusNode.unfocus();
    setState(() => _showSuggestions = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: 'Search university...',
            prefixIcon: const Icon(Icons.school_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: _filter,
        ),
        if (_showSuggestions && _filtered.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).dividerColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final uni = _filtered[index];
                return ListTile(
                  dense: true,
                  title: Text(
                    uni,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  onTap: () => _select(uni),
                );
              },
            ),
          ),
      ],
    );
  }
}
