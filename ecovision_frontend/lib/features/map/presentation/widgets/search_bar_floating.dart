import 'package:flutter/material.dart';

/// Search bar floating trên map
class SearchBarFloating extends StatefulWidget {
  final Function(String)? onSearchChanged;
  final VoidCallback? onTap;
  final String hintText;
  final Color? backgroundColor;
  final double? height;

  const SearchBarFloating({
    super.key,
    this.onSearchChanged,
    this.onTap,
    this.hintText = 'Tìm kiếm',
    this.backgroundColor,
    this.height,
  });

  @override
  State<SearchBarFloating> createState() => _SearchBarFloatingState();
}

class _SearchBarFloatingState extends State<SearchBarFloating> {
  final TextEditingController _controller = TextEditingController();
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _showClearButton = _controller.text.isNotEmpty;
      });
      widget.onSearchChanged?.call(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? 48,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        onTap: widget.onTap,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),
          suffixIcon: _showClearButton
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[400]),
                  onPressed: () {
                    _controller.clear();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
