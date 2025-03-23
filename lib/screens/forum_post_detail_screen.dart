import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'translated_text.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

// ForumPostDetailScreen shows the details of a forum post, including its replies,
// and provides options for the post owner to edit or delete the post.
class ForumPostDetailScreen extends StatefulWidget {
  final Map<String, dynamic> post; // The post data passed into this screen.
  final int index; // The index of the post in the stored list.
  final String preferredLanguage; // The language to be used for translations.

  const ForumPostDetailScreen(
      {Key? key,
      required this.post,
      required this.index,
      required this.preferredLanguage})
      : super(key: key);

  @override
  State<ForumPostDetailScreen> createState() => _ForumPostDetailScreenState();
}

class _ForumPostDetailScreenState extends State<ForumPostDetailScreen> {
  late Map<String, dynamic> postDetail; // Local mutable copy of the post details.
  final TextEditingController _replyController = TextEditingController(); // Controller for the reply input field.

  // Saves the current postDetail data back to SharedPreferences.
  Future<void> _savePost() async {
    final prefs = await SharedPreferences.getInstance();
    // Retrieve all stored forum posts using the global key "forum_posts".
    List<String> stored = prefs.getStringList('forum_posts') ?? [];
    // Update the specific post at the provided index.
    stored[widget.index] = jsonEncode(postDetail);
    await prefs.setStringList('forum_posts', stored);
  }

  // Allows the user (post owner) to edit the post content.
  Future<void> _editPost() async {
    // Initialize a controller with the current post content.
    TextEditingController _editController =
        TextEditingController(text: postDetail["content"]);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Post"),
          content: TextField(
            controller: _editController,
            maxLines: null, // Allow multiple lines.
            decoration: const InputDecoration(
              labelText: "Post Content",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            // Cancel editing.
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
            // Save changes and update the post.
            TextButton(
                onPressed: () async {
                  setState(() {
                    // Update the postDetail with the new trimmed content.
                    postDetail["content"] = _editController.text.trim();
                  });
                  await _savePost(); // Save the updated post.
                  Navigator.pop(context); // Close the dialog.
                },
                child: const Text("Save"))
          ],
        );
      },
    );
  }

  // Deletes the current post after user confirmation.
  Future<void> _deletePost() async {
    bool confirmed = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Post"),
          content: const Text("Are you sure you want to delete this post?"),
          actions: [
            // Cancel deletion.
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel")),
            // Confirm deletion.
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Delete")),
          ],
        );
      },
    );
    if (confirmed) {
      final prefs = await SharedPreferences.getInstance();
      List<String> stored = prefs.getStringList('forum_posts') ?? [];
      stored.removeAt(widget.index); // Remove the post at the given index.
      await prefs.setStringList('forum_posts', stored);
      Navigator.pop(context); // Exit the detail screen after deletion.
    }
  }

  // Adds a reply to the post.
  // The reply includes the text, timestamp, and replier's username and email.
  void _addReply(String reply) async {
    final user = FirebaseAuth.instance.currentUser;
    String username = (user != null &&
            user.displayName != null &&
            user.displayName!.isNotEmpty)
        ? user.displayName!
        : (user?.email ?? "User");
    String userEmail = user?.email ?? "";
    Map<String, dynamic> replyData = {
      "reply": reply, // The reply content.
      "timestamp": DateTime.now().toIso8601String(), // Current time as timestamp.
      "username": username,  // Save the replier's username.
      "userEmail": userEmail // Save the replier's email for ownership checking.
    };
    // Append the new reply to the list of replies in postDetail.
    (postDetail['replies'] as List).add(replyData);
    await _savePost(); // Save the updated post with the new reply.
    _replyController.clear(); // Clear the reply input field.
    setState(() {}); // Refresh the UI.
  }

  // Allows editing of an existing reply at the given reply index.
  Future<void> _editReply(int replyIndex) async {
    Map<String, dynamic> reply = (postDetail['replies'] as List)[replyIndex];
    // Create a controller initialized with the current reply content.
    TextEditingController _editReplyController =
        TextEditingController(text: reply["reply"]);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Reply"),
          content: TextField(
            controller: _editReplyController,
            maxLines: null, // Allow multiple lines.
            decoration: const InputDecoration(
              labelText: "Reply Content",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            // Cancel editing the reply.
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
            // Save changes to the reply.
            TextButton(
                onPressed: () async {
                  setState(() {
                    // Update the reply content with the new trimmed text.
                    (postDetail['replies'] as List)[replyIndex]["reply"] =
                        _editReplyController.text.trim();
                    // Optionally update the timestamp to the current time.
                    (postDetail['replies'] as List)[replyIndex]["timestamp"] =
                        DateTime.now().toIso8601String();
                  });
                  await _savePost(); // Save the updated reply.
                  Navigator.pop(context); // Close the dialog.
                },
                child: const Text("Save"))
          ],
        );
      },
    );
  }

  // Deletes a reply at the specified reply index after confirmation.
  Future<void> _deleteReply(int replyIndex) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Reply"),
          content: const Text("Are you sure you want to delete this reply?"),
          actions: [
            // Cancel deletion.
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel")),
            // Confirm deletion.
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Delete")),
          ],
        );
      },
    );
    if (confirmed) {
      setState(() {
        // Remove the reply from the list.
        (postDetail['replies'] as List).removeAt(replyIndex);
      });
      await _savePost(); // Save the updated post after deleting the reply.
    }
  }

  @override
  void initState() {
    super.initState();
    // Create a local copy of the post passed in through the widget.
    postDetail = Map<String, dynamic>.from(widget.post);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    // Get the current user's email for ownership checks.
    String currentUserEmail = currentUser?.email ?? "";
    String formattedTime = "";
    try {
      // Format the post timestamp into a readable format.
      DateTime ts = DateTime.parse(postDetail['timestamp']);
      formattedTime = DateFormat('dd-MM-yyyy HH:mm').format(ts.toLocal());
    } catch (e) {}
    // Determine if the current user is the owner of the post.
    bool isOwner = currentUserEmail == postDetail["userEmail"];
    return Scaffold(
      appBar: AppBar(
        // Display the title using TranslatedText for multi-language support.
        title: TranslatedText(
            text: "Post Details", targetLanguage: widget.preferredLanguage),
        // If the current user is the owner, show a popup menu for editing or deleting.
        actions: isOwner
            ? [
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == "Edit") {
                      _editPost(); // Trigger edit action.
                    } else if (value == "Delete") {
                      _deletePost(); // Trigger delete action.
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: "Edit", child: Text("Edit")),
                    const PopupMenuItem(
                        value: "Delete", child: Text("Delete")),
                  ],
                )
              ]
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Overall padding for the content.
        child: Column(
          children: [
            // Display the poster's username and formatted timestamp.
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Posted by: ${postDetail['username']}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(formattedTime,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            // Show the main post content.
            Text(postDetail['content'] ?? ""),
            const Divider(),
            // Display the list of replies.
            Expanded(
              child: ListView.builder(
                itemCount: (postDetail['replies'] as List).length,
                itemBuilder: (context, index) {
                  final reply = (postDetail['replies'] as List)[index];
                  String replyTime = "";
                  try {
                    // Format each reply's timestamp.
                    DateTime rt = DateTime.parse(reply['timestamp']);
                    replyTime =
                        DateFormat('dd-MM-yyyy HH:mm').format(rt.toLocal());
                  } catch (e) {}
                  // Determine if the current user is the owner of the reply.
                  bool isReplyOwner =
                      currentUserEmail == (reply["userEmail"] ?? "");
                  return ListTile(
                    title: Text(reply['username'] ?? "Anonymous"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(reply['reply'] ?? ""),
                        Text(replyTime,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    // If the reply belongs to the current user, show options to edit or delete.
                    trailing: isReplyOwner
                        ? PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == "Edit") {
                                _editReply(index); // Edit reply action.
                              } else if (value == "Delete") {
                                _deleteReply(index); // Delete reply action.
                              }
                            },
                            itemBuilder: (context) => [
                                  const PopupMenuItem(
                                      value: "Edit", child: Text("Edit")),
                                  const PopupMenuItem(
                                      value: "Delete", child: Text("Delete")),
                                ],
                          )
                        : null,
                  );
                },
              ),
            ),
            // Input field for adding a new reply.
            TextField(
              controller: _replyController,
              decoration: const InputDecoration(
                labelText: "Enter reply",
                border: OutlineInputBorder(),
              ),
            ),
            // Button to submit a new reply.
            ElevatedButton(
              onPressed: () {
                if (_replyController.text.trim().isNotEmpty) {
                  _addReply(_replyController.text.trim());
                }
              },
              child: TranslatedText(
                  text: "Reply", targetLanguage: widget.preferredLanguage),
            )
          ],
        ),
      ),
    );
  }
}
