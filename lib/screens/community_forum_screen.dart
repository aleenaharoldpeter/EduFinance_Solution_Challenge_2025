import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'translated_text.dart';
import 'forum_post_detail_screen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class CommunityForumScreen extends StatefulWidget {
  final String preferredLanguage;
  const CommunityForumScreen({Key? key, required this.preferredLanguage})
      : super(key: key);

  @override
  State<CommunityForumScreen> createState() => _CommunityForumScreenState();
}

class _CommunityForumScreenState extends State<CommunityForumScreen> {
  List<Map<String, dynamic>> posts = []; // Stores forum posts
  final TextEditingController _postController = TextEditingController(); // Controller for new post input

  // Loads forum posts from shared preferences
  Future<void> _loadPosts() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> stored = prefs.getStringList('forum_posts') ?? [];
    setState(() {
      posts = stored.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
    });
  }

  // Adds a new post to the forum
  Future<void> _addPost(String content) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    Map<String, dynamic> post = {
      "username": user.displayName?.isNotEmpty == true ? user.displayName! : (user.email ?? "User"),
      "userEmail": user.email, // Store email to check ownership later
      "content": content,
      "timestamp": DateTime.now().toIso8601String(), // Store timestamp for sorting
      "replies": [] // Initialize replies list
    };
    
    posts.insert(0, post); // Add new post at the beginning
    final prefs = await SharedPreferences.getInstance();
    List<String> stored = posts.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList('forum_posts', stored);
    _postController.clear(); // Clear input field after posting
    setState(() {});
  }

  // Edits an existing post
  Future<void> _editPost(int index, Map<String, dynamic> post) async {
    TextEditingController _editController =
        TextEditingController(text: post["content"]);
    
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Post"),
          content: TextField(
            controller: _editController,
            maxLines: null,
            decoration: const InputDecoration(
              labelText: "Post Content",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
            TextButton(
                onPressed: () async {
                  setState(() {
                    posts[index]["content"] = _editController.text.trim();
                  });
                  final prefs = await SharedPreferences.getInstance();
                  List<String> stored = posts.map((e) => jsonEncode(e)).toList();
                  await prefs.setStringList('forum_posts', stored);
                  Navigator.pop(context);
                },
                child: const Text("Save"))
          ],
        );
      },
    );
  }

  // Deletes a post after confirmation
  Future<void> _deletePost(int index) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Post"),
          content: const Text("Are you sure you want to delete this post?"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel")),
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Delete")),
          ],
        );
      },
    );
    if (confirmed) {
      setState(() {
        posts.removeAt(index);
      });
      final prefs = await SharedPreferences.getInstance();
      List<String> stored = posts.map((e) => jsonEncode(e)).toList();
      await prefs.setStringList('forum_posts', stored);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPosts(); // Load forum posts when the screen initializes
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    String currentUserEmail = currentUser?.email ?? "";
    
    return Scaffold(
      appBar: AppBar(
        title: TranslatedText(
            text: "Community Forum", targetLanguage: widget.preferredLanguage),
      ),
      body: Column(
        children: [
          // Text input for new post
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _postController,
              decoration: InputDecoration(
                labelText: "Enter your post",
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          
          // Post button
          ElevatedButton(
            onPressed: () {
              if (_postController.text.trim().isNotEmpty) {
                _addPost(_postController.text.trim());
              }
            },
            child: TranslatedText(
                text: "Post", targetLanguage: widget.preferredLanguage),
          ),
          const Divider(),
          
          // List of forum posts
          Expanded(
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                String formattedTime = "";
                try {
                  DateTime ts = DateTime.parse(post['timestamp']);
                  formattedTime =
                      DateFormat('dd-MM-yyyy HH:mm').format(ts.toLocal());
                } catch (e) {}
                
                return ListTile(
                  title: Text(post['username'] ?? ""),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post['content'] ?? ""),
                      Text(formattedTime,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  // Show edit/delete options only for the post owner
                  trailing: (currentUserEmail == post["userEmail"])
                      ? PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == "Edit") {
                              _editPost(index, post);
                            } else if (value == "Delete") {
                              _deletePost(index);
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
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ForumPostDetailScreen(
                          post: post,
                          index: index,
                          preferredLanguage: widget.preferredLanguage,
                        ),
                      ),
                    );
                    _loadPosts(); // Refresh posts after returning from detail screen
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
