import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'item_detail_screen.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  List favourites = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFavourites();
  }

  Future<void> fetchFavourites() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> favIds = prefs.getStringList('favorites') ?? [];

      if (favIds.isEmpty) {
        setState(() {
          favourites = [];
          isLoading = false;
        });
        return;
      }

      // Fetch all items and filter locally to display details for favorites
      final uri = Uri.http('10.0.2.2:8000', '/items', {'limit': '1000'});
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        List allItems = json.decode(response.body);
        if (mounted) {
          setState(() {
            favourites = allItems.where((item) => favIds.contains(item['id'].toString())).toList();
            isLoading = false;
          });
        }
      } else {
        _showError("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Failed to load favourites.");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Favourites"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchFavourites,
              color: Colors.indigo,
              child: favourites.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite_border, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text("No favourite games yet.", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: favourites.length,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      itemBuilder: (context, index) {
                        final item = favourites[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.redAccent,
                              child: Icon(Icons.favorite, color: Colors.white, size: 20),
                            ),
                            title: Text(item["title"] ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("${item["category"]} • ${item["year"]}"),
                            trailing: const Icon(Icons.chevron_right, color: Colors.indigo),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ItemDetailScreen(item: Map<String, dynamic>.from(item)),
                                ),
                              );
                              fetchFavourites(); // Refresh when coming back in case it was un-favourited
                            },
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
