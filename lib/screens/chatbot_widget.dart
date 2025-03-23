import 'package:flutter/material.dart';
import 'translated_text.dart';

class ChatBotWidget extends StatefulWidget {
  final String preferredLanguage; // Stores user's preferred language for translations
  
  const ChatBotWidget({Key? key, required this.preferredLanguage}) : super(key: key);

  @override
  _ChatBotWidgetState createState() => _ChatBotWidgetState();
}

class _ChatBotWidgetState extends State<ChatBotWidget> {
  // List of frequently asked questions (FAQs) with corresponding answers
  final List<Map<String, String>> faqOptions = [
    {
      'question': 'How do I filter scholarships?',
      'answer': 'Use the filter options on the Scholarship Filter screen to narrow down results by state, qualification, and category.'
    },
    {
      'question': 'How do I bookmark a scholarship?',
      'answer': 'Simply tap the "Add to Bookmark" button on a scholarship card to save it for later.'
    },
    {
      'question': 'How do I set a reminder?',
      'answer': 'Tap "Set Reminder" on the scholarship details to receive a notification one day before the deadline.'
    },
    {
      'question': 'How do I track my applications?',
      'answer': 'Go to the Application Tracker screen to update and view your application statuses.'
    }
  ];

  // Function to display a popup dialog with the selected question and answer
  void _showAnswer(String question, String answer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TranslatedText(
          text: question,
          targetLanguage: widget.preferredLanguage,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Styled title text
        ),
        content: TranslatedText(
          text: answer,
          targetLanguage: widget.preferredLanguage, // Translate answer based on preferred language
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close dialog on button press
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16), // Add padding for better spacing
      height: 300, // Fixed height for chatbot widget
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align elements to the start of the column
        children: [
          TranslatedText(
            text: "How can I help you?",
            targetLanguage: widget.preferredLanguage,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Styled header text
          ),
          const Divider(), // Add a horizontal line separator
          Expanded(
            child: ListView.builder(
              itemCount: faqOptions.length, // Number of FAQ items
              itemBuilder: (context, index) {
                final option = faqOptions[index];
                return ListTile(
                  title: TranslatedText(
                    text: option['question']!, // Display FAQ question
                    targetLanguage: widget.preferredLanguage,
                  ),
                  onTap: () => _showAnswer(option['question']!, option['answer']!), // Show answer on tap
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}