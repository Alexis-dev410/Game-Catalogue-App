import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_item_screen.dart';
import 'dart:convert';

class ItemDetailScreen extends StatefulWidget {
  final Map<String, dynamic> item;

  const ItemDetailScreen({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  bool isFavorite = false;
  late Map<String, dynamic> currentItem;

  @override
  void initState() {
    super.initState();
    currentItem = widget.item;
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favorites = prefs.getStringList('favorites') ?? [];
    setState(() {
      isFavorite = favorites.contains(currentItem['id'].toString());
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favorites = prefs.getStringList('favorites') ?? [];
    final String itemId = currentItem['id'].toString();

    setState(() {
      if (isFavorite) {
        favorites.remove(itemId);
        isFavorite = false;
      } else {
        favorites.add(itemId);
        isFavorite = true;
      }
    });

    await prefs.setStringList('favorites', favorites);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isFavorite ? "Added to favorites" : "Removed from favorites"),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.indigo,
        ),
      );
    }
  }

  Future<void> deleteItem(BuildContext context) async {
    try {
      final uri = Uri.http('10.0.2.2:8000', '/items/${currentItem['id']}');
      final response = await http.delete(uri).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Item deleted successfully")),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Delete failed: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentItem['title'] ?? 'Game Details'),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.redAccent : null,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentItem['title'] ?? 'No Title',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildInfoChip(Icons.category, currentItem['category'] ?? 'N/A'),
                const SizedBox(width: 10),
                _buildInfoChip(Icons.calendar_today, currentItem['year']?.toString() ?? 'N/A'),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 24),
                const SizedBox(width: 5),
                Text(
                  '${currentItem['rating'] ?? '0.0'} / 10.0',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 30, thickness: 1),
            const Text(
              'Description',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            const SizedBox(height: 10),
            Text(
              currentItem['description'] ?? 'No description provided.',
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 20),
            if (currentItem.containsKey('platform') && currentItem['platform'] != null && currentItem['platform'].toString().isNotEmpty) ...[
              const Text(
                'Platform',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
              const SizedBox(height: 5),
              Text(
                currentItem['platform'],
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditItemScreen(item: Map<String, dynamic>.from(currentItem)),
                        ),
                      );
                      if (result != null && result is Map<String, dynamic>) {
                        setState(() {
                          currentItem = result;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text("Delete"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Delete Game"),
                          content: const Text("Are you sure you want to delete this game? This action cannot be undone."),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true), 
                              child: const Text("Delete", style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        deleteItem(context);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              'Added on: ${currentItem['created_at']?.toString().split('T')[0] ?? 'Unknown'}',
              style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.indigo),
      label: Text(label),
      backgroundColor: Colors.indigo.withOpacity(0.05),
      side: BorderSide(color: Colors.indigo.withOpacity(0.1)),
    );
  }
}
