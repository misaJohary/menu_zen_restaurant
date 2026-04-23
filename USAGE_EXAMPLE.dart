// // This file demonstrates how to use the updated AddItemWidget with multilingual support
// // DO NOT run this file - it's for documentation purposes only
//
// import 'package:flutter/material.dart';
// import 'package:flutter_form_builder/flutter_form_builder.dart';
// import 'package:menu_zen_restaurant/features/presentations/widgets/add_item_widget.dart';
// import 'package:menu_zen_restaurant/features/presentations/widgets/multilingual_field.dart';
//
// class MenuItemFormExample extends StatefulWidget {
//   const MenuItemFormExample({super.key});
//
//   @override
//   State<MenuItemFormExample> createState() => _MenuItemFormExampleState();
// }
//
// class _MenuItemFormExampleState extends State<MenuItemFormExample> {
//   final formKey = GlobalKey<FormBuilderState>();
//   final GlobalKey<_AddItemWidgetState> addItemWidgetKey = GlobalKey();
//
//   void _handleSubmit() {
//     if (formKey.currentState?.saveAndValidate() ?? false) {
//       // Get all form values
//       final formValues = formKey.currentState!.value;
//
//       // Get translations from the AddItemWidget
//       final translations = addItemWidgetKey.currentState?.translations ?? {};
//
//       // Example: Create a menu item model with translations
//       final menuItemData = {
//         'price': formValues['price'],
//         'categoryId': formValues['category_id'],
//         'imageUrl': formValues['image_url'],
//         'translations': translations,
//         // translations structure:
//         // {
//         //   'en': {'name': 'Pizza', 'description': 'Delicious pizza'},
//         //   'fr': {'name': 'Pizza', 'description': 'Pizza délicieuse'},
//         //   'es': {'name': 'Pizza', 'description': 'Pizza deliciosa'}
//         // }
//       };
//
//       print('Menu item data: $menuItemData');
//
//       // TODO: Send to your controller/BLoC for API submission
//       // controller.createMenuItem(menuItemData);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Add Menu Item')),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: AddItemWidget(
//           key: addItemWidgetKey,
//           title: 'Add New Menu Item',
//           formKey: formKey,
//
//           // Define which fields should be multilingual
//           multilingualFields: [
//             MultilingualField(name: 'name', label: 'Item Name', maxLines: 1),
//             MultilingualField(
//               name: 'description',
//               label: 'Description',
//               maxLines: 3,
//             ),
//           ],
//
//           // Regular non-multilingual fields
//           formBuilderFields: [
//             SizedBox(height: 16),
//             FormBuilderTextField(
//               name: 'price',
//               decoration: InputDecoration(
//                 labelText: 'Price',
//                 border: OutlineInputBorder(),
//                 prefixText: '\$',
//               ),
//               keyboardType: TextInputType.number,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Price is required';
//                 }
//                 return null;
//               },
//             ),
//             SizedBox(height: 16),
//             FormBuilderDropdown(
//               name: 'category_id',
//               decoration: InputDecoration(
//                 labelText: 'Category',
//                 border: OutlineInputBorder(),
//               ),
//               items: [
//                 DropdownMenuItem(value: 1, child: Text('Appetizers')),
//                 DropdownMenuItem(value: 2, child: Text('Main Course')),
//                 DropdownMenuItem(value: 3, child: Text('Desserts')),
//               ],
//               validator: (value) {
//                 if (value == null) {
//                   return 'Category is required';
//                 }
//                 return null;
//               },
//             ),
//             SizedBox(height: 16),
//             FormBuilderTextField(
//               name: 'image_url',
//               decoration: InputDecoration(
//                 labelText: 'Image URL',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//           ],
//
//           // Action buttons
//           confirmationButton: ElevatedButton(
//             onPressed: _handleSubmit,
//             child: Text('Save Menu Item'),
//           ),
//           cancelButton: OutlinedButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel'),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ============================================================================
// // Alternative: Using AddItemWidget without multilingual fields (backward compatible)
// // ============================================================================
//
// class SimpleFormExample extends StatefulWidget {
//   const SimpleFormExample({super.key});
//
//   @override
//   State<SimpleFormExample> createState() => _SimpleFormExampleState();
// }
//
// class _SimpleFormExampleState extends State<SimpleFormExample> {
//   final formKey = GlobalKey<FormBuilderState>();
//
//   void _handleSubmit() {
//     if (formKey.currentState?.saveAndValidate() ?? false) {
//       final formValues = formKey.currentState!.value;
//       print('Form values: $formValues');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AddItemWidget(
//       title: 'Add Category',
//       formKey: formKey,
//       // No multilingualFields parameter - works as before
//       formBuilderFields: [
//         FormBuilderTextField(
//           name: 'name',
//           decoration: InputDecoration(
//             labelText: 'Category Name',
//             border: OutlineInputBorder(),
//           ),
//         ),
//         SizedBox(height: 16),
//         FormBuilderTextField(
//           name: 'description',
//           decoration: InputDecoration(
//             labelText: 'Description',
//             border: OutlineInputBorder(),
//           ),
//           maxLines: 3,
//         ),
//       ],
//       confirmationButton: ElevatedButton(
//         onPressed: _handleSubmit,
//         child: Text('Save'),
//       ),
//     );
//   }
// }
//
// // ============================================================================
// // Accessing translation data programmatically
// // ============================================================================
//
// class AdvancedUsageExample extends StatefulWidget {
//   const AdvancedUsageExample({super.key});
//
//   @override
//   State<AdvancedUsageExample> createState() => _AdvancedUsageExampleState();
// }
//
// class _AdvancedUsageExampleState extends State<AdvancedUsageExample> {
//   final formKey = GlobalKey<FormBuilderState>();
//   final GlobalKey<_AddItemWidgetState> addItemWidgetKey = GlobalKey();
//
//   void _checkTranslationCompleteness() {
//     final widgetState = addItemWidgetKey.currentState;
//     if (widgetState != null) {
//       // Get specific translation
//       final englishName = widgetState.getTranslation('en', 'name');
//       print('English name: $englishName');
//
//       // Check if all translations are complete
//       // Note: You'd need to pass the languages list here
//       // final isComplete = widgetState.areAllTranslationsComplete(languages);
//
//       // Get all translations
//       final allTranslations = widgetState.translations;
//       print('All translations: $allTranslations');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AddItemWidget(
//       key: addItemWidgetKey,
//       title: 'Menu Item',
//       formKey: formKey,
//       multilingualFields: [MultilingualField(name: 'name', label: 'Name')],
//       formBuilderFields: [],
//       confirmationButton: ElevatedButton(
//         onPressed: _checkTranslationCompleteness,
//         child: Text('Check Translations'),
//       ),
//     );
//   }
// }
