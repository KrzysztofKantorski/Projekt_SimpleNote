import 'package:flutter/material.dart';

/// Pasek wyszukiwania z przyciskiem cofnięcia i czyszczenia
class SnSearchBar extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final VoidCallback? onBack;
  final String placeholder;

  const SnSearchBar({
    super.key,
    this.onChanged,
    this.onBack,
    this.placeholder = 'Search notes',
  });

  @override
  State<SnSearchBar> createState() => _SnSearchBarState();
}

class _SnSearchBarState extends State<SnSearchBar> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
      widget.onChanged?.call(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Strzałka wstecz
          GestureDetector(
            onTap: widget.onBack ?? () => Navigator.of(context).pop(),
            child: const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.arrow_back, size: 22, color: Colors.black),
            ),
          ),
          // Pole tekstowe
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: true,
              style: const TextStyle(fontSize: 16, color: Colors.black),
              decoration: InputDecoration(
                hintText: widget.placeholder,
                hintStyle: const TextStyle(
                    color: Color(0xFFAAAAAA), fontSize: 16),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          // Przycisk X — tylko gdy jest tekst
          if (_hasText)
            GestureDetector(
              onTap: _clear,
              child: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.close, size: 20, color: Color(0xFF888888)),
              ),
            ),
        ],
      ),
    );
  }
}
