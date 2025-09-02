import 'package:flutter/material.dart';

class EditDeleteIcon extends StatelessWidget {
  const EditDeleteIcon({
    super.key,
    required this.onDelete,
    required this.onEdit,
    this.isVertical = false,
    this.iconSize,
  });

  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool? isVertical;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    if (isVertical!) {
      return Column(
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            iconSize: iconSize,
            onPressed: onEdit,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            iconSize: iconSize,
            onPressed: onDelete,
            color: Colors.red,
          ),
        ],
      );
    }
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.edit),
          iconSize: iconSize,
          onPressed: onEdit,
        ),
        IconButton(
          icon: Icon(Icons.delete),
          iconSize: iconSize,
          onPressed: onDelete,
          color: Colors.red,
        ),
      ],
    );
  }
}