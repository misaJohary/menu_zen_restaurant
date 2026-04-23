import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'card_list_tile.dart';
import 'edit_delete_icon.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Column(children: [item, item, item]),
    );
  }
}

final item = CardListTile(
  title: Text('Lorem'),
  subtitle: Text('Lorem ipsum'),
  trailing: EditDeleteIcon(onDelete: () {}, onEdit: () {}),
);
