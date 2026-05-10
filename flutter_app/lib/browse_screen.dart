import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'item_detail_screen.dart';
import 'add_item_screen.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  List items = [];
  bool isLoading = true;
  String selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  // Unified Category List
  final List<String> categories = [
    'All', 'Action', 'RPG', 'Adventure', 'Sports', 'Strategy', 'Simulation', 'Shooter', 'Sandbox', 'Racing', 'Fighting'
  ];

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final Map<String, String> queryParams = {};
      if (_searchController.text.isNotEmpty) {
        queryParams['search'] = _searchController.text.trim();
      }
      if (selectedCategory != 'All') {
        queryParams['category'] = selectedCategory;
      }

      final uri = Uri.http('10.0.2.2:8000', '/items', queryParams);
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            items = json.decode(response.body);
            isLoading = false;
          });
        }
      } else {
        _showError("Server returned error: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Connection failed. Is the Python backend running?");
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
        title: const Text("Game Catalog"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search games...",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty 
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            fetchItems();
                          },
                        )
                      : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                  onChanged: (val) => setState(() {}),
                  onSubmitted: (_) => fetchItems(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      isExpanded: true,
                      items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (newValue) {
                        setState(() => selectedCategory = newValue!);
                        fetchItems();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchItems,
              child: items.isEmpty
                  ? const Center(child: Text("No games found."))
                  : ListView.builder(
                      itemCount: items.length,
                      padding: const EdgeInsets.only(bottom: 80),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          elevation: 2,
                          child: ListTile(
                            title: Text(item["title"] ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("${item["category"]} • ${item["year"]}"),
                            trailing: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item["rating"]?.toString() ?? "0.0",
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                              ),
                            ),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ItemDetailScreen(item: Map<String, dynamic>.from(item)),
                                ),
                              );
                              fetchItems();
                            },
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddItemScreen()),
          );
          if (result == true) fetchItems();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
