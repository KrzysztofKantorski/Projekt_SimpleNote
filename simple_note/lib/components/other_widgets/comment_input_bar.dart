import 'package:flutter/material.dart';

/// Pasek pisania komentarza z polem tekstowym i przyciskiem wysyłania
/// Wyświetlany nad klawiaturą na ekranie komentarzy
class SnCommentInputBar extends StatefulWidget {
  final ValueChanged<String>? onSubmit;
  final bool autofocus;

  const SnCommentInputBar({
    super.key,
    this.onSubmit,
    this.autofocus = false,
  });

  @override
  State<SnCommentInputBar> createState() => _SnCommentInputBarState();
}

class _SnCommentInputBarState extends State<SnCommentInputBar> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_hasText) return;
    widget.onSubmit?.call(_controller.text.trim());
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFEEEEEE), width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Strzałka wstecz
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back,
                size: 22, color: Color(0xFF444444)),
          ),
          const SizedBox(width: 10),
          // Pole tekstowe
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: widget.autofocus,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submit(),
              style: const TextStyle(fontSize: 15, color: Colors.black),
              decoration: const InputDecoration(
                hintText: 'Your comment',
                hintStyle: TextStyle(color: Color(0xFFAAAAAA), fontSize: 15),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Przycisk wyślij
          GestureDetector(
            onTap: _hasText ? _submit : null,
            child: Icon(
              Icons.send_outlined,
              size: 22,
              color: _hasText ? Colors.black : const Color(0xFFCCCCCC),
            ),
          ),
        ],
      ),
    );
  }
}
