import 'package:flutter/material.dart';
import '../theme/theme.dart';

class RestrictedWordsScreen extends StatefulWidget {
  const RestrictedWordsScreen({super.key});

  @override
  State<RestrictedWordsScreen> createState() => _RestrictedWordsScreenState();
}

class _RestrictedWordsScreenState extends State<RestrictedWordsScreen> {
  final List<String> _restrictedWords = [
    'spam',
    'advertisement',
    'promotion',
  ];

  final TextEditingController _wordController = TextEditingController();
  bool _autoDeleteMessages = true;
  bool _notifyOnBlock = false;

  @override
  void dispose() {
    _wordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwiftSnapTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Restricted Words',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with gradient
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    SwiftSnapTheme.primaryPurple,
                    SwiftSnapTheme.primaryPink,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: SwiftSnapTheme.primaryPurple.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.block,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Word Filtering',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_restrictedWords.length} words blocked',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Info banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[300], size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Messages containing these words will be automatically filtered',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Add Word Section
            _buildSectionTitle('Add Restricted Word'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: SwiftSnapTheme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: SwiftSnapTheme.borderColor,
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _wordController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Enter word or phrase',
                        hintStyle: TextStyle(color: Colors.white38),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        SwiftSnapTheme.primaryPurple,
                        SwiftSnapTheme.primaryPink,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _addWord,
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Settings
            _buildSectionTitle('Filter Settings'),
            const SizedBox(height: 12),
            _buildSwitchTile(
              'Auto-delete Messages',
              'Automatically delete messages with restricted words',
              Icons.auto_delete,
              _autoDeleteMessages,
              (value) => setState(() => _autoDeleteMessages = value),
            ),
            const SizedBox(height: 12),
            _buildSwitchTile(
              'Notification on Block',
              'Get notified when a message is blocked',
              Icons.notifications,
              _notifyOnBlock,
              (value) => setState(() => _notifyOnBlock = value),
            ),
            const SizedBox(height: 24),

            // Restricted Words List
            _buildSectionTitle('Restricted Words (${_restrictedWords.length})'),
            const SizedBox(height: 12),
            if (_restrictedWords.isEmpty)
              _buildEmptyState()
            else
              _buildWordsList(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: SwiftSnapTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SwiftSnapTheme.borderColor,
          width: 1,
        ),
      ),
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                SwiftSnapTheme.primaryPurple.withOpacity(0.3),
                SwiftSnapTheme.primaryPink.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 13,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: SwiftSnapTheme.primaryPurple,
      ),
    );
  }

  Widget _buildWordsList() {
    return Container(
      decoration: BoxDecoration(
        color: SwiftSnapTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SwiftSnapTheme.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        children: _restrictedWords
            .asMap()
            .entries
            .map((entry) {
              final index = entry.key;
              final word = entry.value;
              return Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.block,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      word,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => _removeWord(word),
                    ),
                  ),
                  if (index < _restrictedWords.length - 1)
                    const Divider(
                      color: Colors.white10,
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                ],
              );
            })
            .toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: SwiftSnapTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SwiftSnapTheme.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle,
            size: 48,
            color: Colors.green[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'No Restricted Words',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add words you want to filter from messages',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _addWord() {
    final word = _wordController.text.trim().toLowerCase();
    if (word.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a word'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_restrictedWords.contains(word)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Word already in the list'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _restrictedWords.add(word);
      _wordController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"$word" added to restricted words'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _removeWord(String word) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SwiftSnapTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Remove Restricted Word',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Remove "$word" from the restricted words list?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _restrictedWords.remove(word);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('"$word" removed')),
              );
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
