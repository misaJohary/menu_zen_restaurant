import 'package:flutter/material.dart';

class EditDeleteIcon extends StatelessWidget {
  const EditDeleteIcon({
    super.key,
    required this.onDelete,
    required this.onEdit,
  });

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(icon: Icon(Icons.edit), onPressed: onEdit),
        IconButton(icon: Icon(Icons.delete), onPressed: onDelete, color: Colors.red,),
      ],
    );
  }
}