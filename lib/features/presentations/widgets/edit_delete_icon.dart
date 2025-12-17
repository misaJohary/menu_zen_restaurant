import 'package:flutter/material.dart';

class EditDeleteIcon extends StatelessWidget {
  const EditDeleteIcon({
    super.key,
    this.onDelete,
    this.onEdit,
    this.isVertical = false,
    this.iconSize,
  });

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool? isVertical;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    if (isVertical!) {
      return Column(
        children: [
          if(onEdit != null)
          IconButton(
            icon: Icon(Icons.edit),
            iconSize: iconSize,
            onPressed: onEdit,
          ),
          if(onDelete != null)
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
        if(onEdit != null)
        IconButton(
          icon: Icon(Icons.edit),
          iconSize: iconSize,
          onPressed: onEdit,
        ),
        if(onDelete != null)
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