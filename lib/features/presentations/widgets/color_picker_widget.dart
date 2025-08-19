import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../../core/constants/constants.dart';

class ColorPickerWidget extends StatefulWidget {
  const ColorPickerWidget({
    super.key,
    required this.onColorSelected,
    this.selectedColor,
  });

  final Color? selectedColor;
  final ValueSetter<Color?> onColorSelected;

  @override
  State<ColorPickerWidget> createState() => _ColorPickerWidgetState();
}

class _ColorPickerWidgetState extends State<ColorPickerWidget> {
  int? selectedIndex = 7;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.selectedColor != null) {
        Logger().d('Selected color: ${widget.selectedColor}');
        selectedIndex = colors.indexWhere(
          (color) => color["color"] == widget.selectedColor,
        );
        widget.onColorSelected(colors[selectedIndex!]["color"]);
      }
      widget.onColorSelected(colors[selectedIndex!]["color"]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: colors.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // 4 items per row
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 4, // makes them look like rectangles
      ),
      itemBuilder: (context, index) {
        final item = colors[index];
        final isSelected = selectedIndex == index;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedIndex = index;
            });
            widget.onColorSelected(colors[index]["color"]);
          },
          child: Container(
            decoration: BoxDecoration(
              color: item["color"],
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: Colors.orange, width: 3)
                  : null,
            ),
            child: Center(
              child: Text(
                item["name"],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: item["textColor"],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
