import 'package:flutter/material.dart';

class EmojiKeyboardTextField extends StatefulWidget {
  final Function(String)? onEmojiSelected;
  final String? initialValue;
  final String hintText;

  const EmojiKeyboardTextField({
    super.key,
    this.onEmojiSelected,
    this.initialValue,
    this.hintText = 'Tap to select emoji',
  });

  @override
  State<EmojiKeyboardTextField> createState() => _EmojiKeyboardTextFieldState();
}

class _EmojiKeyboardTextFieldState extends State<EmojiKeyboardTextField> {
  String selectedEmoji = '';
  bool showKeyboard = false;
  String activeCategory = 'Main Dishes';

  final Map<String, List<String>> foodEmojis = {
    'Main Dishes': [
      '🍕', '🍔', '🌭', '🥪', '🌮', '🌯',
      '🥙', '🧆', '🥘', '🍝', '🍜', '🍲',
      '🍛', '🍱', '🍙', '🍘', '🍚', '🥟',
      '🍳', '🥞', '🧇', '🥓', '🍗', '🍖'
    ],
    'Fruits': [
      '🍎', '🍏', '🍊', '🍋', '🍌', '🍉',
      '🍇', '🍓', '🫐', '🍈', '🍒', '🍑',
      '🥭', '🍍', '🥥', '🥝', '🍅', '🫒'
    ],
    'Vegetables': [
      '🥑', '🍆', '🥔', '🥕', '🌽', '🌶️',
      '🥬', '🥒', '🫑', '🥦', '🧄', '🧅',
      '🍄', '🥜', '🌰', '🫘', '🫛'
    ],
    'Desserts': [
      '🍰', '🎂', '🧁', '🥧', '🍮', '🍭',
      '🍬', '🍫', '🍿', '🍩', '🍪', '🌰',
      '🍯', '🧊', '🍨', '🍧', '🥠', '🍡'
    ],
    'Beverages': [
      '☕', '🍵', '🧃', '🥤', '🧋', '🍼',
      '🥛', '🍺', '🍻', '🥂', '🍷', '🥃',
      '🍸', '🍹', '🍾', '🧊', '💧', '🫖'
    ],
    'Fast Food': [
      '🍕', '🍔', '🍟', '🌭', '🥪', '🌮',
      '🌯', '🥙', '🍿', '🥤', '🍦', '🍩'
    ],
    'Healthy': [
      '🥗', '🥑', '🥦', '🥕', '🍅', '🥒',
      '🫑', '🥬', '🧄', '🧅', '🥝', '🫐',
      '🥛', '🥤', '💧', '🌱', '🥜', '🫘'
    ],
    'Breakfast': [
      '🥐', '🍞', '🥖', '🥨', '🥯', '🧈',
      '🥞', '🧇', '🍳', '🥓', '🥚', '🍯',
      '🥣', '🥤', '☕', '🥛', '🧃', '🍊'
    ]
  };

  final List<String> popularEmojis = [
    '🍕', '🍔', '🥗', '🍰', '☕', '🍜',
    '🥘', '🍳', '🥐', '🍿', '🥑', '🌮',
    '🍝', '🍲', '🧁', '🥤', '🍎', '🥦',
    '🍓', '🧀', '🥓', '🍯', '🍪', '🥛'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      selectedEmoji = widget.initialValue!;
    }
  }

  void _handleEmojiSelect(String emoji, void Function(void Function()) setState) {
    setState(() {
      selectedEmoji = emoji;
      showKeyboard = false;
    });

    if (widget.onEmojiSelected != null) {
      widget.onEmojiSelected!(emoji);
    }
  }

  Widget _buildTextField() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(context: context, builder: (context)=> _buildEmojiKeyboard());
        // setState(() {
        //   showKeyboard = !showKeyboard;
        // });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: showKeyboard ? Colors.orange : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Text(
              selectedEmoji.isEmpty ? '😊' : selectedEmoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedEmoji.isEmpty
                    ? widget.hintText
                    : '$selectedEmoji Food Category',
                style: TextStyle(
                  fontSize: 16,
                  color: selectedEmoji.isEmpty ? Colors.grey.shade600 : Colors.black,
                ),
              ),
            ),
            Icon(
              showKeyboard ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: foodEmojis.keys.map((category) {
                bool isActive = activeCategory == category;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      activeCategory = category;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.white : Colors.transparent,
                      border: isActive
                          ? const Border(bottom: BorderSide(color: Colors.orange, width: 2))
                          : null,
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isActive ? Colors.orange : Colors.grey.shade600,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      }
    );
  }

  Widget _buildEmojiGrid() {
    List<String> emojis = foodEmojis[activeCategory] ?? [];

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          height: 200,
          padding: const EdgeInsets.all(12),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 1,
            ),
            itemCount: emojis.length,
            itemBuilder: (context, index) {
              String emoji = emojis[index];
              return GestureDetector(
                onTap: () => _handleEmojiSelect(emoji, setState),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.transparent,
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }
    );
  }

  Widget _buildPopularSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Access - Popular',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: popularEmojis.map((emoji) {
              return GestureDetector(
                onTap: () => _handleEmojiSelect(emoji, setState),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.orange.shade50,
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiKeyboard() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(8),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.black.withOpacity(0.1),
      //       blurRadius: 10,
      //       offset: const Offset(0, 4),
      //     ),
      //   ],
      // ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCategoryTabs(),
          _buildEmojiGrid(),
          _buildPopularSection(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTextField();
  }
}