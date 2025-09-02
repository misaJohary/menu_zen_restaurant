import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';

class CustomChipChoice<T> extends StatelessWidget {
  const CustomChipChoice({
    super.key,
    this.padding,
    this.margin,
    required this.label,
    this.labelStyle,
    required this.onSelected,
    this.selected = false,
    required this.item,
    this.selectedLabelStyle,
    this.backGroundColor,
    this.selectedBackGroundColor,
  });

  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final String label;
  final TextStyle? labelStyle;
  final TextStyle? selectedLabelStyle;
  final ValueSetter<T> onSelected;
  final Color? backGroundColor;
  final Color? selectedBackGroundColor;
  final bool selected;
  final T item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onSelected(item),
      child: Container(
        padding:
            padding ??
            EdgeInsets.symmetric(
              vertical: kspacing,
              horizontal: kspacing * 2,
            ),
        margin: margin ?? EdgeInsets.only(right: kspacing * 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kspacing * 3),
          border: Border.all(width: .5, color: Color(0xFF999999)),
          color: selected
              ? selectedBackGroundColor ?? Colors.black
              : backGroundColor ?? Colors.white,
        ),
        child: Text(
          label,
          style: selected
              ? selectedLabelStyle ??
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
              : labelStyle ?? TextStyle(color: Color(0xFF999999)),
        ),
      ),
    );
  }
}
